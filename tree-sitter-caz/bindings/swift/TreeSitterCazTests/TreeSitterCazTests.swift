import XCTest
import SwiftTreeSitter
import TreeSitterCaz

final class TreeSitterCazTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_caz())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Caz grammar")
    }
}
