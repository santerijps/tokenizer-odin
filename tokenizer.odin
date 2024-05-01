package tokenizer

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:text/match"


Token :: struct {type, value: string, line, column: uint}
TokenSpec:: struct {type: string, patterns: []string}
TokenIterator :: struct {text: string, spec_array: []TokenSpec, index: int}


token_iter_init :: #force_inline proc(text: string, spec_array: []TokenSpec) -> TokenIterator {
    return TokenIterator {text, spec_array, 0}
}


token_iter_next :: proc(iter: ^TokenIterator) -> (token: Token, ok: bool) {
    for i := iter.index; i < len(iter.text); i += 1 {
        for spec in iter.spec_array {
            for pattern in spec.patterns {
                matcher := match.matcher_init(iter.text, pattern, i)
                value, ok := match.matcher_match(&matcher)
                if ok {
                    line, column := get_line_and_column(iter.text, i)
                    token.type = spec.type
                    token.value = value
                    token.line = line
                    token.column = column
                    iter.index = i + len(value)
                    return token, true
                }
            }
        }
    }
    return token, false
}


tokenize :: proc(text: string, spec_array: []TokenSpec) -> (tokens: [dynamic]Token) {
    iter := token_iter_init(text, spec_array)
    for {
        token, ok := token_iter_next(&iter)
        if !ok do break
        append(&tokens, token)
    }
    return tokens
}


@(private)
get_line_and_column :: proc(text: string, index: int) -> (line, column: uint) {
    line, column = 1, 1
    for i := 0; i < index; i += 1 {
        if text[i] == '\n' {
            line += 1;
            column = 1;
        }
        else {
            column += 1;
        }
    }
    return line, column
}


read_token_spec_json :: proc(path: string) -> []TokenSpec {
    bytes, ok := os.read_entire_file(path)
    if !ok {
        fmt.eprintfln("Failed to read file: %s", path)
        os.exit(1)
    }
    return parse_token_spec_json(bytes)
}


parse_token_spec_json :: proc(json_bytes: []byte) -> (spec_array: []TokenSpec) {
    err := json.unmarshal(json_bytes, &spec_array)
    if err != nil {
        fmt.eprintln("Invalid spec file!", err)
        os.exit(1)
    }

    // Prefix patterns with ^ to ensure that only that start of text is matched
    for spec in spec_array {
        for i := 0; i < len(spec.patterns); i += 1 {
            if !strings.has_prefix(spec.patterns[i], "^") {
                spec.patterns[i] = strings.join([]string{"^", spec.patterns[i]}, "")
            }
        }
    }

    return spec_array
}
