package lexer

import "core:strings"

Token :: struct {
    type: enum {
        tok_err,
        tok_eof,
        
        tok_preproc_imp,
        tok_preproc_use,

        tok_imp_path,

        tok_opoint,
        tok_cpoint,
        tok_oparen,
        tok_cparen,
        tok_obrace,
        tok_cbrace,

        tok_type_slice,
        tok_type_str,

        tok_func_ret,

        tok_const_decl,
        tok_mut_decl,

        tok_pack_res,

        tok_string,
        tok_num,
        tok_ident
    },

    val: string
}

input: string

cur: i32;

get_tok :: proc() -> Token {
    tok: Token

    switch input[cur] {
        case ' ':
            for strings.is_space(cast(rune)input[cur]) do cur += 1

        case '#':
            str := strings.builder_make()
            strings.write_rune(&str, cast(rune)input[cur])
            cur += 1

            for (input[cur] >= 'a' && input[cur] <= 'z') ||
                (input[cur] >= 'A' && input[cur] <= 'Z') ||
                (input[cur] == '_') { 
                strings.write_rune(&str, cast(rune)input[cur])
                cur += 1 
            }

            name := strings.to_string(str)

            switch name {
            case "#imp":
                tok.type = .tok_preproc_imp
                tok.val = "#imp"
            case "#use":
                tok.type = .tok_preproc_use
                tok.val = "#use"
            }

        case 'a'..='z', 'A'..='Z':
            str := strings.builder_make()
            strings.write_rune(&str, cast(rune)input[cur])
            cur += 1

            for (input[cur] >= 'a' && input[cur] <= 'z') ||
                (input[cur] >= 'A' && input[cur] <= 'Z') ||
                (input[cur] >= '0' && input[cur] <= '9') ||
                (input[cur] == '_') { 
                strings.write_rune(&str, cast(rune)input[cur])
                cur += 1 
            }

            tok.type = .tok_ident
            tok.val = strings.clone(strings.to_string(str))

        case 0:
            tok.type = .tok_eof
            tok.val = transmute(string)[]u8{0}

        case '0'..='9':
            str := strings.builder_make()
            strings.write_rune(&str, cast(rune)input[cur])
            cur += 1

            for (input[cur] >= '0' && input[cur] <= '9') ||
                (input[cur] == '.') {
                strings.write_rune(&str, cast(rune)input[cur])
                cur += 1
            }

            tok.type = .tok_num
            tok.val = strings.clone(strings.to_string(str))
    }
    
    return tok
}
