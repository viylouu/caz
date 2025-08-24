package lexer

import "core:text/regex"

Regex :: regex.Regular_Expression

Token_Type :: enum {
    tok_err,
    tok_eof,
    tok_none,
    
    tok_preproc,

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

    tok_func_call,

    tok_expr,
    tok_ident,
    tok_num
}

tok_name := [Token_Type]string{
    .tok_err = "ERROR",
    .tok_eof = "EOF",
    .tok_none = "how did this get here?",

    .tok_preproc = "PREPROC",

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

    .tok_func_call = "FUNC call",
    
    .tok_expr = "EXPRESSION",
    .tok_ident = "IDENT",
    .tok_num = "NUM"
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




/*grammars := [Token_Type]Rule{
    .tok_ident = rule_token("/[a-z_][a-z0-9_]+/i"),
    .tok_num =   rule_token("/[0-9]+/"),

    .tok_expr =  rule_choice_ref(.tok_ident, .tok_num)
}*/




input: string
