import SwiftUI

/// A vertical line down the middle of its frame.
public struct VLine: Shape {
    public init() {}

    nonisolated public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
    }
}

/// A horizontal line across the middle of its frame.
public struct HLine: Shape {
    public init() {}

    nonisolated public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}
