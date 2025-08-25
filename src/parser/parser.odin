package parser

import "core:strings"
import "core:text/regex"


grammar := [Token_Type]Gram{
    .tok_err = "unique1", .tok_none = "unique2",
    .tok_ignore = "[ \t\r\n]*",
    .tok_start = repeat(choice(.tok_ident, .tok_num)),

    .tok_ident = "[a-zA-Z_][a-zA-Z0-9_]*",
    .tok_num = "[0-9\\._]+"
}


token :: proc(expr: string) -> Rule {
    reg, err := regex.create(expr)
    assert(err == nil, "invalid regex! (err)")
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

    tok_ident,
    tok_num
}

tok_name := [Token_Type]string{
    .tok_err = "ERROR", .tok_none = "",
    .tok_ignore = "IGNORE",
    .tok_start = "START",

    .tok_ident = "IDENT",
    .tok_num = "NUMBER"
}
