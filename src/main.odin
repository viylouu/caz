package main

import "core:fmt"
import "core:os"

main :: proc() {
    fmt.printf("building \"%s\"\n", os.args[1])

    data, err := os.read_entire_file_from_filename_or_err(os.args[1])
    assert(err == nil, "failed to load file!")
}
