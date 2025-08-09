/// Represents a user of the application.
class User {
  /// The unique identifier for the user.
  final String id;

  /// The user's display name.
  final String name;

  /// The user's email address.
  final String email;

  /// Creates a new [User] instance.
  User({required this.id, required this.name, required this.email});
}
