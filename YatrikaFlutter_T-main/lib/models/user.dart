class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? role;
  final bool? active;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.role,
    this.active,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString(),
    avatarUrl: json['avatarUrl']?.toString(),
    role: json['role']?.toString(),
    active: json['active'] as bool?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (email != null) 'email': email,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (role != null) 'role': role,
    if (active != null) 'active': active,
  };
}
