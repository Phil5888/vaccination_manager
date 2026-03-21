import 'dart:typed_data';

class AppUserEntity {
  const AppUserEntity({required this.id, required this.username, required this.profilePicture, required this.isActive, required this.createdAt});

  final int? id;
  final String username;
  final Uint8List? profilePicture;
  final bool isActive;
  final DateTime createdAt;

  String get initials {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return '?';
    }

    final parts = trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  AppUserEntity copyWith({int? id, String? username, Uint8List? profilePicture, bool? isActive, DateTime? createdAt, bool clearProfilePicture = false}) {
    return AppUserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePicture: clearProfilePicture ? null : profilePicture ?? this.profilePicture,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
