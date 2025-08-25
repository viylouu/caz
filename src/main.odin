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
                fmt.printf("%*s[%s, TOKEN, valid = %v]\n", indent*2, "", parser.tok_name[sym], rule.expr != nil)
            case .REF:
                fmt.printf("%*s[%s, REF, %s]\n", indent*2, "", parser.tok_name[sym], parser.tok_name[rule.ref])
            case:
                fmt.printf("%*s[%s, %s]\n", indent*2, "", parser.tok_name[sym], parser.rule_name[rule.type])
            }

            for field in rule.fields do print_rule(field, indent+1, .tok_none)
        }
    }

    for rule, sym in parser.grammar do print_rule(rule, 0, sym)
}
