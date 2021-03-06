//// SYMKRemainingTimeInfobarItem.swift
//
// Copyright (c) 2019 - Sygic a.s.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SygicUIKit


/// Item for infobar controller showing time to the end of route
public class SYMKRemainingTimeInfobarItem: SYMKInfobarItem {
    public var type: SYMKInfobarItemType = .remainingTime(0)
    public let view: UIView = SYUIInfobarLabel()
    
    public func update(with valueType: SYMKInfobarItemType) {
        switch valueType {
        case .remainingTime(let time):
            type = valueType
            guard let label = view as? SYUIInfobarLabel else { return }
            label.text = formattedValue(time)
        default:
            break
        }
    }
        
    private func formattedValue(_ remainingTime: TimeInterval?) -> String {
        if let time = remainingTime {
            if time < 60 {
                return "\(time)\(LS("sec"))"
            } else if time < 60*60 {
                return String(format: "%i%@", Int(time/60), LS("min"))
            } else {
                let min = Float(time).truncatingRemainder(dividingBy: 60*60)
                return String(format: "%i%@%i%@", Int(time/60/60), LS("h"), Int(min/60), LS("min"))
            }
        }
        return ""
    }
}
