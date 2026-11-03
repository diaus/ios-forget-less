//
//  UIApplication+ResignFocus.swift
//  Utils
//
//  Created by Andrew Shapoval on 02/11/2026.
//

// The package's tests also build for the Mac, which has no UIKit.
#if canImport(UIKit)
import UIKit

extension UIApplication {
    /// Takes keyboard focus from whatever field holds it, so the keyboard goes down.
    public func resignFocus() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
