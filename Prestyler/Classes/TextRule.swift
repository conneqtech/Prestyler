//
//  TextRule.swift
//  Prestyler
//
//  Created by Ilya Krupko on 28/02/2019.
//

import Foundation

struct TextRule {
    let appliedStyle: [Any]
    var positions: [Int]

    var color: UIColor? {
        for style in appliedStyle where style is UIColor {
            return style as? UIColor
        }
        for style in appliedStyle where style is String {
            if  let hexString = style as? String,
                let color = hexStringToUIColor(hex: hexString ) {
                return color
            }
        }
        return nil
    }

    var font: UIFont? {
        for style in appliedStyle where style is UIFont {
            return style as? UIFont
        }
        return nil
    }

    var fontSize: CGFloat {
        // if defined explicitly by Int return
        for style in appliedStyle where style is Int {
            return CGFloat(style as! Int)
        }
        // or retrieve from font
        if let font = font {
            return font.pointSize
        }
        return CGFloat(Prestyler.defaultFontSize)
    }

    mutating func correctPositions(oldValue: Int, newValue: Int) {
        let diff = oldValue - newValue
        for index in 0..<positions.count {
            if positions[index] > oldValue {
                positions[index] = positions[index] - diff
            }
        }
    }

    func applyTo(text: inout NSMutableAttributedString) {
        // calculate ranges
        let ranges = getRangesFromPositions(maxPosition: text.length - 1)
        // apply
        for range in ranges {
            // colors
            if let color = self.color {
                text.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: color,
                                  range: range)
            }
            for style in appliedStyle {
                if let precolor = style as? Precolor {
                    let type = precolor.isForeground ? NSAttributedString.Key.foregroundColor : NSAttributedString.Key.backgroundColor
                    if precolor.random == 0 {
                        text.addAttribute(type, value: precolor.colorToApply, range: range)
                    } else {
                        let splittedRange = range.splitUnitary()
                        for range in splittedRange {
                            text.addAttribute(type, value: precolor.colorToApply, range: range)
                        }
                    }
                }
            }
            // font and size
            if appliedStyle.contains(where: { $0 is Int }) {
                text.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], range: range)
            }
            if appliedStyle.contains(where: { $0 as? Prestyle == .bold }) {
                text.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)], range: range)
            }
            if appliedStyle.contains(where: { $0 as? Prestyle == .italic }) {
                text.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: fontSize)], range: range)
            }
            if let font = font {
                text.addAttributes([NSAttributedString.Key.font: font], range: range)
            }
            // other properties
            if appliedStyle.contains(where: { $0 as? Prestyle == .strikethrough }) {
                text.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            if appliedStyle.contains(where: { $0 as? Prestyle == .underline }) {
                text.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
        }
    }

    fileprivate func getRangesFromPositions(maxPosition: Int) -> [NSRange] {
        var positions = self.positions
        var ranges = [NSRange]()
        while positions.count > 0 {
            if positions.count == 1 {
                ranges.append(NSRange(location: positions[0], length: maxPosition))
                positions =  Array(positions.dropFirst())
            }
            if positions.count > 1 {
                ranges.append(NSRange(location: positions[0], length: positions[1] - positions[0]))
                positions =  Array(positions.dropFirst(2))
            }
        }
        return ranges
    }
}

extension NSRange {
    func splitUnitary() -> [NSRange] {
        var result = [NSRange]()
        for index in 0..<self.length {
            result.append(NSRange(location: self.location + index, length: 1))
        }
        return result
    }
}