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
      '::',
      $.parameter_list_defn,
      '>>',
      $._type,
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
      $.slice_type
      // todo: add more types
    ),

    primitive_type: $ => choice(
      'raw',
      'str'
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

    _statement: $ => choice(
      $.return_statement,
      $._preproc,
      $.function_call
    ),

    return_statement: $ => seq(
      'return',
      $._expression
    ),

    function_call: $ => seq(
      optional(repeat1(seq($.identifier, '::'))),
      $.identifier,
      $.parameter_list
    ),

    _expression: $ => choice(
      $.identifier,
      $.number,
      $.string
      // todo: more expressions
    ),

    string: $ => /"([^"\\]|\\.)*"/,

    _preproc: $ => choice(
      $.preproc_import
    ),

    preproc_import: $ => seq(
      '#imp ',
      '<',
      seq($.identifier, repeat(seq('::', $.identifier))),
      '>'
    ),

    identifier: $ => /[a-z]+/,
    number: $ => /\d+/,

    comment: $ => token(choice(
      seq('//', /.*/),
      seq('/*', repeat(choice(/[^*]/, /\*+[^*/]/)), '*/')
    ))
  }
});

