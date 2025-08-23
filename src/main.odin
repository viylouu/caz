package main

import "core:fmt"
import "core:os"

main :: proc() {
    fmt.println("hello world")
    fmt.println(os.args[0])
    fmt.println(os.args[1:])
}
