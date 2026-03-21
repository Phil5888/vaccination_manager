import 'dart:typed_data';

import 'package:vaccination_manager/domain/entities/app_user_entity.dart';

class AppUserModel {
  const AppUserModel({required this.id, required this.username, required this.profilePicture, required this.isActive, required this.createdAt});

  final int? id;
  final String username;
  final Uint8List? profilePicture;
  final bool isActive;
  final DateTime createdAt;

  factory AppUserModel.fromMap(Map<String, Object?> map) {
    return AppUserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      profilePicture: map['profile_picture'] as Uint8List?,
      isActive: (map['is_active'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  factory AppUserModel.fromEntity(AppUserEntity user) {
    return AppUserModel(id: user.id, username: user.username, profilePicture: user.profilePicture, isActive: user.isActive, createdAt: user.createdAt);
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'username': username, 'profile_picture': profilePicture, 'is_active': isActive ? 1 : 0, 'created_at': createdAt.toIso8601String()};
  }

  AppUserEntity toEntity() {
    return AppUserEntity(id: id, username: username, profilePicture: profilePicture, isActive: isActive, createdAt: createdAt);
  }
}
