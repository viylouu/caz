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
    return Rule{ type = .TOKEN, expr = reg, fields = nil }
}

repeat :: proc(rule: Onion) -> Gram { return Rule{ type = .REPEAT, expr = nil, fields = onions_to_rules([]Onion{rule}) } }
optional :: proc(rule: Onion) -> Gram { return Rule{ type = .OPTIONAL, expr = nil, fields = onions_to_rules([]Onion{rule}) } }
choice :: proc(rules: ..Onion) -> Gram { return Rule{ type = .CHOICE, expr = nil, fields = onions_to_rules(rules) } }
seq :: proc(rules: ..Onion) -> Gram { return Rule{ type = .SEQ, expr = nil, fields = onions_to_rules(rules) } }

onions_to_rules :: proc(rules: []Onion) -> []Rule {
    fields := make([]Rule, len(rules))
    for rule, i in rules {
        switch r in rule {
        case Gram: switch g in r {
            case Rule: fields[i] = g
            case string: fields[i] = token(g)
            }
        case Token_Type: switch g in grammar[r] {
            case Rule: fields[i] = g
            case string: fields[i] = token(g)
            } 
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
    fields: []Rule
}

Rule_Type :: enum {
    TOKEN,
    REPEAT,
    OPTIONAL,
    CHOICE,
    SEQ
}

rule_name := [Rule_Type]string{
    .TOKEN = "TOKEN",
    .REPEAT = "REPEAT",
    .OPTIONAL = "OPTIONAL",
    .CHOICE = "CHOICE",
    .SEQ = "SEQ"
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
