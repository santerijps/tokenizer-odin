# Tokenizer

This is a simple generic tokenizer package and executable implemented in Odin.
Tokenization is done with [Lua pattern matching](https://www.lua.org/pil/20.2.html).

## Package

To get started, download this repository and place it withing your project.
Then you'll be able to import the tokenizer package with:

```odin
import "path/to/tokenizer"
```

The `tokenizer` Odin package exposes the following API:

```odin
// Types
Token :: struct {type, value: string, line, column: uint}
TokenSpec:: struct {type: string, patterns: []string}
TokenIterator :: struct {text: string, spec_array: []TokenSpec, index: int}

// Tokenization functions
token_iter_init :: proc(text: string, spec_array: []TokenSpec) -> TokenIterator
token_iter_next :: proc(iter: ^TokenIterator) -> (token: Token, ok: bool)
tokenize :: proc(text: string, spec_array: []TokenSpec) -> (tokens: [dynamic]Token)

// Token spec functions
read_token_spec_json :: proc(path: string) -> (spec_array: []TokenSpec, ok: bool)
parse_token_spec_json :: proc(json_bytes: []byte) -> (spec_array: []TokenSpec, ok: bool)
```

## Command line executable

### Building from source

The command line executable can be built with `make`:

```bash
cd tokenizer
make debug # no optimizations, create a .pdb file
make release # optimize for speed
```

See the [Makefile](./Makefile) for compilation details.

### Usage

Run the `tokenizer` executable to see the following output:

```
Usage: tokenizer.exe [options] file...
Options:
  -spec <file>         Token spec file to use during tokenization.
  -out <file>          Optional, write output to a file instead of stdout.
  -pretty              Optional, pretty print output JSON.
```

Example usage:

```bash
# Pass input file to tokenizer
tokenizer input.txt -spec my-token-spec.json -pretty # Prints tokens to stdout as a JSON list

# Pipe input to tokenizer
cat input.txt | tokenizer -spec my-token-spec.json -pretty
```

Example spec using Lua patterns:

```json
[{
  "type": "keyword",
  "patterns": ["if", "else"]
}, {
  "type": "number",
  "patterns": ["%d+"]
}, {
  "type": "undefined",
  "patterns": ["."]
}]
```

See the [examples](./examples/) directory for more examples.
