class UserEntity {
  final int? id;
  final String username;
  final String? profilePicturePath;

  const UserEntity({
    this.id,
    required this.username,
    this.profilePicturePath,
  });

  UserEntity copyWith({
    int? id,
    String? username,
    String? profilePicturePath,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }
}
