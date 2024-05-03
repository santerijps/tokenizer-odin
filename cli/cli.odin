package cli

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import tokenizer ".."


AppConfig :: struct {spec: []tokenizer.TokenSpec, text: string, pretty: bool, out: string}


main :: proc() {
  config := parse_argv()
  tokens := tokenizer.tokenize(config.text, config.spec)
  output := json_bytefy(tokens, config.pretty)

  if len(config.out) > 0 {
      os.write_entire_file(config.out, output)
  } else {
      fmt.println(string(output))
  }
}


@(private)
parse_argv :: proc() -> (AppConfig) {
    config: AppConfig = {nil, "", false, ""}

    if len(os.args) == 1 {
        throw(
            "Usage: %s [options] file...\n" +
            "Options:\n" +
            "  -spec <file>         Token spec file to use during tokenization.\n" +
            "  -out <file>          Optional, write output to a file instead of stdout.\n" +
            "  -pretty              Optional, pretty print output JSON.",
            filepath.base(os.args[0])
        )
    }

    for i := 1; i < len(os.args); i += 1 {
        if os.args[i] == "-spec" && i + 1 < len(os.args) {
            i += 1
            spec_array, ok := tokenizer.read_token_spec_json(os.args[i])
            if !ok do throw("Failed to read token spec: %s", os.args[i])
            config.spec = spec_array

        } else if os.args[i] == "-out" && i + 1 < len(os.args) {
            i += 1
            config.out = os.args[i]

        } else if os.args[i] == "-pretty" {
            config.pretty = true

        } else {
            config.text = string(read_file_bytes(os.args[i]))
        }
    }

    if config.spec == nil do throw("No spec file provided!")

    if len(config.text) == 0 {
        config.text = string(read_stdin_bytes())
    }

    return config
}


@(private)
json_bytefy :: proc(data: any, pretty: bool) -> []byte {
    bytes, err := json.marshal(data, {pretty = pretty, use_spaces = true, spaces = 2})
    if err != nil do throw("Failed to convert data to JSON:", err)
    return bytes
}


@(private)
read_stdin_bytes :: proc() -> []byte {
    bytes, ok := os.read_entire_file_from_handle(os.stdin)
    if !ok do throw("Failed to read stdin! Did you forget to pass a source file or pipe text into stdin?")
    return bytes
}


@(private)
read_file_bytes :: proc(path: string) -> []byte {
    bytes, ok := os.read_entire_file(path)
    if !ok do throw("Failed to read file: %s!", path)
    return bytes
}


@(private)
throw :: proc(format_string: string, args: ..any) {
    fmt.eprintfln(format_string, ..args)
    os.exit(1)
}
