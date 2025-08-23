; import println, or "puts"
declare i32 @puts(ptr captures(none)) nounwind

; string constant: "hello world\n"
@.str0 = private constant [12 x i8] c"hello world\00"

define i32 @main(i32 %argc, i8** %argv) {
    call i32 @puts(ptr @.str0)
    ret i32 0
}
