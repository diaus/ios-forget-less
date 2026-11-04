/// What submitting the composer did.
enum ComposerSubmission {
    /// A Task was added, and the composer stays up for the next one.
    case added
    /// The edited Task was renamed; nothing is left to save.
    case renamed
}
