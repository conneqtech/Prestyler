//
//  Prestyler.swift
//  Pods-Prestyler_Example
//
//  Created by Ilya Krupko on 28/02/2019.
//

import Foundation

/// Prestyler provides static methods to manage rules.
public final class Prestyler {
    struct Rule {
        let pattern: String
        var styles: [Any]
    }

    static var defaultFontSize = 17

    static var rules = [
        Rule(pattern: "<b>", styles: [Prestyle.bold]),
        Rule(pattern: "<i>", styles: [Prestyle.italic]),
        Rule(pattern: "<bi>", styles: [Prestyle.boldItalic]),
        Rule(pattern: "<strike>", styles: [Prestyle.strikethrough]),
        Rule(pattern: "<underline>", styles: [Prestyle.underline])
    ]

    // MARK: - Public methods

    /// Defines new rule using patters and styles to apply.
    ///
    /// - Parameters:
    ///   - pattern: pattern, for example "<red>"
    ///   - styles: can be objects of sdifferent types, including Int, UIColor, Prestyle etc.
    static public func defineRule(_ pattern: String, _ styles: Any...) {
        rules.removeAll(where: { $0.pattern == pattern })
        rules.append(Rule(pattern: pattern, styles: styles))
    }

    ///
    static public func removeAllRules() {
        rules.removeAll()
    }

    // MARK: - Private methods

    static func findTextRules(_ text: inout String) -> [TextRule] {
        var textRules = [TextRule]()
        for rule in rules {
            var positions = text.indexes(of: rule.pattern)
            if positions.count > 0 {
                correctPositions(&positions, rule.pattern.count, &textRules)
                text = text.replacingOccurrences(of: rule.pattern, with: "")
                textRules.append(TextRule(styles: rule.styles, positions: positions))
            }
        }
        return textRules
    }

    static func correctPositions(_ positions: inout [Int], _ cutlength: Int, _ existingRules: inout [TextRule]) {
        var offsets = [(Int, Int, Int)]()
        var diff = -cutlength
        if positions.count > 0 {
            let oldValue = positions[0]
            offsets.append((oldValue, diff, Int.max))
        }
        for index in 1..<positions.count {
            diff -= cutlength
            let oldValue = positions[index]
            let newValue = positions[index] - cutlength * index
            positions[index] = newValue
            offsets.append((oldValue, diff, Int.max))
            offsets[index-1].2 = oldValue
        }
        for i in 0..<existingRules.count {
            existingRules[i].correctPositions(offsets: offsets)
        }
    }


    private static func correctPositionsAccording(_ positions: inout [Int], _ length: Int) {
        for index in 1..<positions.count where index > 0 {
            positions[index] = positions[index] - length * index
        }
    }
}

fileprivate extension StringProtocol where Index == String.Index {
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Int] {
        var result: [Int] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound.utf16Offset(in: self))
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
