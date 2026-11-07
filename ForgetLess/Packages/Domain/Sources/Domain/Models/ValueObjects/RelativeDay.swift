/// Where a Day sits relative to Today.
public enum RelativeDay: Sendable {
    /// Before Yesterday.
    case beforeToday
    case yesterday
    case today
    case tomorrow
    case later
}
