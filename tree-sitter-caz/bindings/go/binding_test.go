package tree_sitter_caz_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_caz "github.com/viylouu/caz/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_caz.Language())
	if language == nil {
		t.Errorf("Error loading Caz grammar")
	}
}
