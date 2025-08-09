/// Provides an abstraction for the current time.
///
/// Using a [ClockProvider] allows for injecting a fixed clock during tests,
/// making time-dependent logic predictable and verifiable.
abstract class ClockProvider {
  /// Returns the current [DateTime].
  DateTime now();
}

/// A [ClockProvider] that returns the real system time.
///
/// This is the standard implementation to be used in the production application.
class SystemClock implements ClockProvider {
  /// Creates a [SystemClock].
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
