package main

import "lexer"

import "core:fmt"
import "core:os"

main :: proc() {
    fmt.printf("building \"%s\"\n", os.args[1])

    ok, _, tok := lexer.match_rule(lexer.grammars[.tok_start], os.args[1], 0, .tok_start)

    act_tok, is_tok := tok.?
    assert(ok && is_tok, "failed!")

    print_token :: proc(t: lexer.Token, indent: int) {
        fmt.printf("%*s[%s, \"%s\"]\n", indent*2, "", t.type, t.val)
        for child in t.fields do print_token(child, indent+1)
    }

    print_token(act_tok, 0)
}
