/**
 * @file a low level qop lang designed for ease of use in game / engine dev
 * @author viylouu <viylouu@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "caz",

  rules: {
    // TODO: add the actual grammar rules
    source_file: $ => "hello"
  }
});
