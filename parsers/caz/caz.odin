package ts_caz

import ts "../.."

when ODIN_OS == .Windows {
	foreign import ts_caz "parser.lib"
} else {
	foreign import ts_caz "parser.a"
}

foreign ts_caz {
	tree_sitter_caz :: proc() -> ts.Language ---
}

