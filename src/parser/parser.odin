package parser

import "core:strings"
import "core:text/regex"


grammar := [Token_Type]Gram{
    .tok_err = "unique1", .tok_none = "unique2",
    .tok_ignore = "[ \t\r\n]*",
    .tok_start = repeat(choice(._preproc)),

    ._preproc = choice(
        .tok_preproc_lib
        ),

    .tok_preproc_lib = seq(
        "#lib",
        "<",
        .tok_resolve,
        ">",
        optional(seq(
            "as",
            .tok_ident
            ))
        ),

    .tok_resolve = seq(.tok_ident, repeat(seq("::", .tok_ident))),

    .tok_ident = "[a-zA-Z_][a-zA-Z_0-9]*"
}


token :: proc(expr: string) -> Rule {
    expr := strings.concatenate([]string{"^(", expr, ")"})
    reg, err := regex.create(expr)
    assert(err == nil, "invalid regex! (err)")
    delete(expr)
    return Rule{ type = .TOKEN, expr = reg, fields = nil, ref = .tok_none }
}

ref :: proc(tok: Token_Type) -> Rule { return Rule{ type = .REF, expr = nil, fields = nil, ref = tok } }
repeat :: proc(rule: Onion) -> Gram { return Rule{ type = .REPEAT, expr = nil, fields = onions_to_rules([]Onion{rule}), ref = .tok_none } }
optional :: proc(rule: Onion) -> Gram { return Rule{ type = .OPTIONAL, expr = nil, fields = onions_to_rules([]Onion{rule}), ref = .tok_none } }
choice :: proc(rules: ..Onion) -> Gram { return Rule{ type = .CHOICE, expr = nil, fields = onions_to_rules(rules), ref = .tok_none } }
seq :: proc(rules: ..Onion) -> Gram { return Rule{ type = .SEQ, expr = nil, fields = onions_to_rules(rules), ref = .tok_none } }

onions_to_rules :: proc(rules: []Onion) -> []Rule {
    fields := make([]Rule, len(rules))
    for rule, i in rules {
        switch r in rule {
        case Gram: switch g in r {
            case Rule: fields[i] = g
            case string: fields[i] = token(g)
            }
        case Token_Type: fields[i] = ref(r)        
        }
    }

    return fields
}


Onion :: union {
    Gram,
    Token_Type
}

Gram :: union {
    Rule,
    string
}


Rule :: struct {
    type: Rule_Type,
    expr: Maybe(regex.Regular_Expression),
    fields: []Rule,
    ref: Token_Type
}

Rule_Type :: enum {
    TOKEN,
    REPEAT,
    OPTIONAL,
    CHOICE,
    SEQ,
    REF
}

rule_name := [Rule_Type]string{
    .TOKEN = "TOKEN",
    .REPEAT = "REPEAT",
    .OPTIONAL = "OPTIONAL",
    .CHOICE = "CHOICE",
    .SEQ = "SEQ",
    .REF = "REF"
}


Token :: struct {
    type: Token_Type,
    val: string,
    fields: []Token
}

Token_Type :: enum {
    tok_err, tok_none,
    tok_ignore,
    tok_start,

    _preproc,
    tok_preproc_lib,

    tok_resolve,

    tok_ident
}

tok_name := [Token_Type]string{
    .tok_err = "ERROR", .tok_none = "",
    .tok_ignore = "IGNORE",
    .tok_start = "START",

    ._preproc = "_preproc",
    .tok_preproc_lib = "PREPROC lib",
    
    .tok_resolve = "RESOLVE",

    .tok_ident = "IDENT"
}




skip_ignore :: proc(input: string, pos: int) -> int {
    pos := pos
    for {
        ok, new_pos, _ := match_rule(onions_to_rules([]Onion{grammar[.tok_ignore]})[0], input, pos, .tok_ignore)
        if !ok || new_pos == pos do break
        pos = new_pos
    }
    return pos
}

match_rule :: proc(rule: Rule, input: string, pos: int, sym: Token_Type) -> (bool, int, Maybe(Token)) {
    start_pos := pos
    //pos := skip_ignore(input, pos)
    pos := pos

    switch rule.type {
        case .TOKEN:
            assert(rule.expr != nil, "no regex? wtf?")
            reg := rule.expr.?

            cap, ok := regex.match(reg, input[pos:])
            if ok do return true, pos + len(cap.groups[0]), Token{ type = rule.ref, val = cap.groups[0], fields = nil }
            else do return false, pos, nil

        case .REF:
            target_rule := grammar[rule.ref]
            outs: bool
            outp: int
            outt: Maybe(Token)

            switch g in target_rule {
            case Rule: outs, outp, outt = match_rule(g, input, pos, rule.ref)
            case string: outs, outp, outt = match_rule(token(g), input, pos, rule.ref)
            }

            youtt, ok := outt.?
            if ok {  
                youtt.type = rule.ref
                return outs, outp, youtt
            } 
            else do return outs, outp, outt

        case .SEQ:
            childs := make([]Token, len(rule.fields))
            for field, i in rule.fields {
                pos = skip_ignore(input, pos)
                ok, new_pos, child := match_rule(field, input, pos, sym)
                if ok do return true, new_pos, child
            }
            return true, pos, Token{sym, "", childs}

        case .CHOICE:
            for field in rule.fields {
                trial_pos := skip_ignore(input, pos)
                ok, new_pos, child := match_rule(field, input, trial_pos, sym)
                if !ok do continue
                ret, rok := child.?
                if rok do return true, new_pos, Token{ type = ret.type, val = ret.val, fields = ret.fields }
            }
            return false, start_pos, nil

        case .OPTIONAL:
            pos = skip_ignore(input, pos)
            ok, new_pos, child := match_rule(rule.fields[0], input, pos, sym)
            if ok do return true, new_pos, child
            return true, pos, nil

        case .REPEAT:
            childs := [dynamic]Token{}
            for {
                pos = skip_ignore(input, pos)
                ok, new_pos, child := match_rule(rule.fields[0], input, pos, sym)
                if !ok || new_pos == pos do break
                pos = new_pos
                if ok do append(&childs, child.?)
            }
            return true, pos, Token{sym, "", childs[:]}
    }

    return false, pos, nil
}

