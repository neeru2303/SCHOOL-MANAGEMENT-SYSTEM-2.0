class PlatformUser {
  final String id;
  final String sessionId;
  final String email;
  final String firstName;
  final String? lastName;
  final String scope;
  final List<String> roles;
  final List<String> permissions;

  const PlatformUser({
    required this.id,
    required this.sessionId,
    required this.email,
    required this.firstName,
    this.lastName,
    required this.scope,
    required this.roles,
    required this.permissions,
  });

  bool get isSuperAdmin => scope == 'PLATFORM' && roles.contains('SUPER_ADMIN');

  String get fullName => [
    firstName,
    lastName,
  ].where((name) => name != null && name.trim().isNotEmpty).join(' ');

  factory PlatformUser.fromJson(Map<String, dynamic> json) {
    return PlatformUser(
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: json['lastName']?.toString(),
      scope: (json['scope'] ?? '').toString(),
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
      permissions: (json['permissions'] as List<dynamic>? ?? [])
          .map((permission) => permission.toString())
          .toList(),
    );
  }
}
