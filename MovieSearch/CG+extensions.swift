//
//  CG+extensions.swift
//  MovieSearch
//
//  Created by Fritz Anderson on 11/18/19.
//  Copyright © 2019 Fritz Anderson. All rights reserved.
//

import CoreGraphics

public enum CGArithmeticError: Error {
    case divisionByZero
}

extension CGSize {
    /// A new `CGSize` whose components are scaled by a factor.
    public static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    /// Replace a `CGSize` with the same, components scaled by a factor.
    public static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    /// The length from one corner of a rectangle of this size to the opposite.
    ///
    /// `√(width² + height²)`
    public var diagonal: CGFloat {
        return sqrt(width * width + height * height)
    }

    /// The area of a rectangle of this size.
    public var area: CGFloat { return width * height }

    /// `width / height`
    /// - Returns: The ratio of width to height
    /// - Throws: `ArithmeticError.divisionByZero` if `height` is zero.
    public func aspect() throws ->  CGFloat {
        guard height != 0 else { throw CGArithmeticError.divisionByZero }
        return width / height
    }

    /// `width` ↔︎ `height`
    public var swapped: CGSize {
        return CGSize(width: height, height: width)
    }


    /// A `CGSize` with `width` and `height` rounded to the nearest integer.
    var integral: CGSize {
        return CGSize(width: round(width),
                      height: round(height))
    }

    /// A `CGSize` with `width` and `height` truncated to the greatest integer below.
    var floor: CGSize {
        return CGSize(width: Darwin.floor(width),
                      height: Darwin.floor(height))
    }
}


