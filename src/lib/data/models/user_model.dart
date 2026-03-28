import 'package:vaccination_manager/domain/entities/user_entity.dart';

class UserModel {
  final int? id;
  final String username;
  final String? profilePicturePath;

  const UserModel({
    this.id,
    required this.username,
    this.profilePicturePath,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      profilePicturePath: map['profile_picture_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'profile_picture_path': profilePicturePath,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      profilePicturePath: entity.profilePicturePath,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      profilePicturePath: profilePicturePath,
    );
  }
}
