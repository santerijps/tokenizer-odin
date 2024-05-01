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
        fmt.eprintf(
            "Usage: %s [options] file...\n" +
            "Options:\n" +
            "  -spec <file>         Token spec file to use during tokenization.\n" +
            "  -out <file>          Optional, write output to a file instead of stdout.\n" +
            "  -pretty              Optional, pretty print output JSON.\n",
            filepath.base(os.args[0])
        )
        os.exit(1)
    }

    for i := 1; i < len(os.args); i += 1 {
        if os.args[i] == "-spec" && i + 1 < len(os.args) {
            i += 1
            config.spec = tokenizer.read_token_spec_json(os.args[i])

        } else if os.args[i] == "-out" && i + 1 < len(os.args) {
            i += 1
            config.out = os.args[i]

        } else if os.args[i] == "-pretty" {
            config.pretty = true

        } else {
            config.text = string(read_file_bytes(os.args[i]))
        }
    }

    if config.spec == nil {
        fmt.eprintln("No spec file provided!")
        os.exit(1)
    }

    if len(config.text) == 0 {
        config.text = string(read_stdin_bytes())
    }

    return config
}


@(private)
json_bytefy :: proc(data: any, pretty: bool) -> []byte {
    bytes, err := json.marshal(data, {pretty = pretty, use_spaces = true, spaces = 2})
    if err != nil {
        fmt.eprintln("Failed to convert data to JSON:", err)
        os.exit(1)
    }
    return bytes
}


@(private)
read_stdin_bytes :: proc() -> []byte {
    bytes, ok := os.read_entire_file_from_handle(os.stdin)
    if !ok {
        fmt.eprintfln("Failed to read stdin! Did you forget to pass a source file or pipe text into stdin?")
        os.exit(1)
    }
    return bytes
}


@(private)
read_file_bytes :: proc(path: string) -> []byte {
    bytes, ok := os.read_entire_file(path)
    if !ok {
        fmt.eprintfln("Failed to read file: %s!", path)
        os.exit(1)
    }
    return bytes
}
