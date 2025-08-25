package main

import "lexer"

import "core:fmt"
import "core:os"
import "core:math"
import "core:strings"

main :: proc() {
    fmt.printf("building \"%s\"\n", os.args[1])


    fmt.println("\ngrammar:")

    

    print_rule :: proc(r: lexer.Rule, tok: lexer.Token_Type, indent: int) {
        prefix := strings.repeat("  ", indent)
        #partial switch r.type {
        case .TOKEN:
            _, ok := r.match.?
            fmt.printf("%s[%s, TOKEN, has_regex=%v]\n", prefix, lexer.tok_name[tok], ok)
        case .REF:
            fmt.printf("%s[%s, REF, tok=%s]\n", prefix, lexer.tok_name[tok], lexer.tok_name[r.ref])
        case:
            fmt.printf("%s[%s, %s]\n", prefix, lexer.tok_name[tok], lexer.rule_name[r.type])
        }
        for child in r.fields do print_rule(child, .tok_none, indent+1)
    }

    for rule, t in lexer.grammars do print_rule(rule, t, 0)


    data, err := os.read_entire_file_from_filename_or_err(os.args[1])
    assert(err == nil, "failed to load file!")

    fmt.println("\nast:")


    ok, _, tok := lexer.match_rule(lexer.grammars[.tok_start], string(data), 0, .tok_start)

    act_tok, is_tok := tok.?
    assert(ok && is_tok, "failed!")

    print_token :: proc(t: lexer.Token, indent: int) {
        fmt.printf("%*s[%s, \"%s\"]\n", indent*2, "", t.type, t.val)
        for child in t.fields do print_token(child, indent+1)
    }

    print_token(act_tok, 0)
}
