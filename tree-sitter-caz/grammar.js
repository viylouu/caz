/**
 * @file a low level qop lang designed for ease of use in game / engine dev
 * @author viylouu <viylouu@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "caz",

  extras: $ => [
    /\s/,
    $.comment
  ],

  rules: {
    source_file: $ => repeat(choice(
      $._definition,
      $._preproc
    )),

    _definition: $ => choice(
      $.function_definition
    ),

    function_definition: $ => seq(
      $.identifier,
      ':',
      $.decl_const,
      $.parameter_list_defn,
      optional(seq('>>', $._type)),
      $.scope
    ),

    parameter_list_defn: $ => seq(
      '(',
      optional(seq($.parameter_defn, repeat(seq(',', $.parameter_defn)))),
      ')'
    ),

    parameter_defn: $ => seq(
      $.identifier,
      ':',
      $._type
    ),

    parameter_list: $ => seq(
      '(',
      optional(seq($._expression, repeat(seq(',', $._expression)))),
      ')'
    ),

    _type: $ => choice(
      $.primitive_type,
      $.slice_type,
      $.identifier
      // todo: add more types
    ),

    primitive_type: $ => choice(
      'raw',
      'str',

      'i8',
      'i16',
      'i32',
      'i64',
      'u8',
      'u16',
      'u32',
      'u64',
      'f16',
      'f32',
      'f64'
    ),

    slice_type: $ => seq(
      '[]',
      $._type
    ),

    scope: $ => seq(
      '{',
      repeat($._statement),
      '}'
    ),
    
    struct: $ => seq(
      'struct',
      repeat(seq('<<', $.identifier)),
      $.struct_scope
    ),

    struct_scope: $ => seq(
      '{',
      repeat($.var_decl),
      '}'
    ),

    var_decl: $ => seq(
      $.identifier,
      ':',
      optional($._type),
      choice($.decl_mut, $.decl_const),
      $._expression
    ),

    _statement: $ => choice(
      $.return_statement,
      $._preproc,
      $.function_call,
      $.var_decl
    ),

    return_statement: $ => prec.right(seq(
      'ret',
      optional($._expression)
    )),

    function_call: $ => seq(
      optional(seq($.pkg, '::')),
      $.identifier,
      $.parameter_list
    ),

    _expression: $ => choice(
      $.identifier,
      $.number,
      $.string,
      $.struct
      // todo: more expressions
    ),

    string: $ => /"([^"\\]|\\.)*"/,

    back_dir: $ => /\./,

    pkg: $ => prec.left(seq(
      repeat(choice($.back_dir, seq($.identifier, '::'))),
      $.identifier
    )),

    _preproc: $ => choice(
      $.preproc_import,
      $.preproc_library,
      $.preproc_extern,
      $.preproc_use,
      $.preproc_load
    ),

    preproc_library: $ => seq(
      '#lib',
      '<',
      $.pkg,
      '>'
    ),

    preproc_import: $ => seq(
      '#imp',
      '<',
      $.pkg,
      '>',
      optional(seq(
        'as',
        $.identifier
      ))
    ),
  
    preproc_extern: $ => seq(
      '#extern',
      $.identifier,
      $.decl_const,
      $.parameter_list_defn,
      '>>',
      $._type
    ),

    preproc_use: $ => seq(
      '#use',
      $.pkg
    ),

    preproc_load: $ => seq(
      '#load',
      $.parameter_list
    ),

    identifier: $ => /[a-zA-Z]+[a-zA-Z0-9_]*/,
    number: $ => /\d+/,

    decl_const: $ => '~',
    decl_mut: $ => '=',
    assign: $ => '=',

    comment: $ => token(choice(
      seq('//', /.*/),
      seq('/*', repeat(choice(/[^*]/, /\*+[^*/]/)), '*/')
    ))
  }
});

