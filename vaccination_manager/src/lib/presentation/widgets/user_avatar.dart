import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 20});

  final AppUserEntity user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: radius, foregroundImage: _buildImage(user.profilePicture), child: user.profilePicture == null ? Text(user.initials) : null);
  }

  ImageProvider<Object>? _buildImage(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    return MemoryImage(bytes);
  }
}
