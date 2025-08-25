package main

import "parser"

import "core:fmt"
import "core:os"

main :: proc() {
    fmt.printf("building \"%s\"\n", os.args[1])

    data, err := os.read_entire_file_from_filename_or_err(os.args[1])
    assert(err == nil, "failed to load file!")
    src := string(data)
    defer delete(data)

    fmt.println("\nrules:")

    print_rule :: proc(r: parser.Gram, indent: int, sym: parser.Token_Type) {
        str, ok := r.(string)
        if ok do fmt.printf("%*s[%s, REGEX/STR, \"%s\"]\n", indent*2, "", parser.tok_name[sym], str)
        else { rule := r.(parser.Rule) 
        #partial switch rule.type {
            case .TOKEN:
                fmt.printf("%*s[%s, TOKEN, valid = %v", indent*2, "", parser.tok_name[sym], rule.expr != nil)
            case .REF:
                fmt.printf("%*s[%s, REF, %s", indent*2, "", parser.tok_name[sym], parser.tok_name[rule.ref])
            case:
                fmt.printf("%*s[%s, %s", indent*2, "", parser.tok_name[sym], parser.rule_name[rule.type])
            }

            if len(rule.fields) == 0 do fmt.printf("]\n")
            else {
                fmt.println(", fields: [")
                for field in rule.fields do print_rule(field, indent+1, .tok_none)
                fmt.printf("%*s]\n", indent*2, "")
            }
        }
    }

    for rule, sym in parser.grammar do print_rule(rule, 0, sym)

    fmt.println("\ninput:")
    fmt.print(src)

    fmt.println("\nresulting ast:")

    succ, _, maybe_ast := parser.match_rule(parser.grammar[.tok_start].(parser.Rule), src, 0, .tok_start)
    assert(succ, "yayaya")
    ast := maybe_ast.?

    print_tok :: proc(tok: parser.Token, indent: int) {
        fmt.printf("%*s[%s, \"%s\"", indent*2, "", parser.tok_name[tok.type], tok.val)

        if len(tok.fields) == 0 do fmt.printf("]\n")
        else {
            fmt.println(", fields: [")
            for field in tok.fields do print_tok(field, indent+1)
            fmt.printf("%*s]\n", indent*2, "")
        }
    }

    print_tok(ast, 0)
}
