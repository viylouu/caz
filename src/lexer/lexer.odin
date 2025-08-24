package lexer

import "core:strings"
import "core:text/regex"

Regex :: regex.Regular_Expression

Token_Type :: enum {
    tok_err,
    //tok_eof,
    tok_none,

    tok_start,
    
    /*tok_preproc,

    tok_func_defn,
    tok_param_list,
    tok_param,
    tok_scope,

    tok_package,
    tok_pkg_res,

    tok_const_decl,
    tok_mut_decl,

    tok_type_prim,
    tok_type_slice,

    tok_func_call,*/

    tok_expr,
    tok_ident,
    tok_num,

    tok_comment
}

tok_name := [Token_Type]string{
    .tok_err = "ERROR",
    //.tok_eof = "EOF",
    .tok_none = "how did this get here?",

    .tok_start = "START",

    /*.tok_preproc = "PREPROC",

    .tok_func_defn = "DEFN func",
    .tok_param_list = "PARAM list",
    .tok_param = "PARAM",
    .tok_scope = "SCOPE",

    .tok_package = "PKG",
    .tok_pkg_res = "PKG res",

    .tok_const_decl = "DECL const",
    .tok_mut_decl = "DECL mut",

    .tok_type_prim = "TYPE prim",
    .tok_type_slice = "TYPE slice",

    .tok_func_call = "FUNC call",*/
    
    .tok_expr = "EXPRESSION",
    .tok_ident = "IDENT",
    .tok_num = "NUM",

    .tok_comment = "COMMENT"
}

Token :: struct {
    type: Token_Type,
    val: string,
    fields: []Token
}

Rule_Type :: enum {
    TOKEN,
    SEQ,
    CHOICE,
    REPEAT,
    OPTIONAL,
    REF
}

Rule :: struct {
    type: Rule_Type,
    match: Maybe(Regex),
    fields: []Rule,
    ref: Token_Type
}


ref :: proc(toks: []Token_Type) -> []Rule {
    rules := make([]Rule, len(toks))
    for t, i in toks { rules[i].type = .REF ;; rules[i].ref = t }
    return rules
}


rule_token :: proc(str: string) -> Rule {
    reg, err := regex.create_by_user(str)
    assert(err == nil, "failed to make regex!")
    return Rule{.TOKEN, reg, nil, .tok_none}
}

rule_optional :: proc(rule: Rule) -> Rule {
    return Rule{.OPTIONAL, nil, {rule}, .tok_none}
}; rule_optional_ref :: proc(rule: Token_Type) -> Rule {
    return Rule{.OPTIONAL, nil, ref({rule}), .tok_none}
}

rule_repeat :: proc(rule: Rule) -> Rule {
    return Rule{.REPEAT, nil, {rule}, .tok_none}
}; rule_repeat_ref :: proc(rule: Token_Type) -> Rule {
    return Rule{.REPEAT, nil, ref({rule}), .tok_none}
}

rule_choice :: proc(rules: ..Rule) -> Rule { 
    return Rule{.CHOICE, nil, rules, .tok_none}
}; rule_choice_ref :: proc(rules: ..Token_Type) -> Rule {
    return Rule{.CHOICE, nil, ref(rules), .tok_none}
}

rule_seq :: proc(rules: ..Rule) -> Rule {
    return Rule{.SEQ, nil, rules, .tok_none}
}; rule_seq_ref :: proc(rules: ..Token_Type) -> Rule {
    return Rule{.SEQ, nil, ref(rules), .tok_none}
}




grammars := [Token_Type]Rule{
    .tok_none = Rule{}, .tok_err = Rule{},

    .tok_start = rule_repeat(rule_choice_ref(.tok_expr)),

    // yes i use ø for delimiters
    // call me weird

    .tok_ident = rule_token("ø[a-z_][a-z0-9_]+øi"),
    .tok_num =   rule_token("ø[0-9]+ø"),

    .tok_expr =  rule_choice_ref(.tok_ident, .tok_num),

    .tok_comment = rule_choice(
            rule_token("ø//.*ø"),
            rule_token("ø/\\*[.|\n]*?\\*/ø")
        )
}



// 3 am code at 3 pm? how is this possible?
match_rule :: proc(rule: Rule, input: string, pos: int, sym: Token_Type) -> (success: bool, new_pos: int, token: Maybe(Token)) {
    start_pos := pos
    pos := pos

    switch rule.type {
        case .TOKEN:
            cap, ok := regex.match(rule.match.? or_else Regex{}, input[pos:])
            if ok do return true, pos + len(cap.groups[0]), Token{type = sym, val = cap.groups[0], fields = nil}
            else do return false, pos, nil

        case .REF:
            target_rule := grammars[rule.ref]
            return match_rule(target_rule, input, pos, rule.ref)

        case .SEQ:
            childs := make([]Token, len(rule.fields))
            for field, i in rule.fields {
                ok, pos, child := match_rule(field, input, pos, sym)
                if !ok do return false, start_pos, nil
                if _, ok := child.? ; ok do childs[i] = child.? or_else Token{} 
            }
            return true, pos, Token{sym, "", childs}

        case .CHOICE:
            for field in rule.fields {
                ok, new_pos, child := match_rule(field, input, pos, sym)
                if ok do return true, new_pos, Token{sym, "", (child.? or_else Token{}).fields}
            }
            return false, start_pos, nil

        case .OPTIONAL:
            ok, new_pos, child := match_rule(rule.fields[0], input, pos, sym)
            if ok do return true, new_pos, child
            return true, pos, nil

        case .REPEAT:
            childs := [dynamic]Token{}
            for {
                ok, new_pos, child := match_rule(rule.fields[0], input, pos, sym)
                if !ok || new_pos == pos do break
                pos = new_pos
                if _, ok := child.? ; ok do append(&childs, ..child.?.fields)
            }
            return true, pos, Token{sym, "", childs[:]}
    }

    return false, pos, nil
}
