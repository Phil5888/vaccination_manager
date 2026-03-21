import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';

void main() {
  group('AppUserEntity.initials', () {
    test('returns first letter for single-word names', () {
      final user = AppUserEntity(id: 1, username: 'alice', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));

      expect(user.initials, 'A');
    });

    test('returns first and last initials for multi-word names', () {
      final user = AppUserEntity(id: 2, username: 'ada lovelace', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 1));

      expect(user.initials, 'AL');
    });

    test('returns question mark for blank usernames', () {
      final user = AppUserEntity(id: 3, username: '   ', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 1));

      expect(user.initials, '?');
    });
  });

  group('AppUserEntity.copyWith', () {
    test('can clear profile picture explicitly', () {
      final user = AppUserEntity(id: 1, username: 'Alice', profilePicture: Uint8List.fromList(<int>[1, 2, 3]), isActive: true, createdAt: DateTime(2026, 1, 1));

      final updated = user.copyWith(clearProfilePicture: true);

      expect(updated.profilePicture, isNull);
    });
  });
}
