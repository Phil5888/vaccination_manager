import 'package:freezed_annotation/freezed_annotation.dart';

part 'random_user_model.freezed.dart';
part 'random_user_model.g.dart';

@freezed
abstract class RandomUser with _$RandomUser {
  const factory RandomUser({required Name name, required String gender, required String email, required Picture picture}) = _RandomUser;

  factory RandomUser.fromJson(Map<String, dynamic> json) => _$RandomUserFromJson(json);
}

@freezed
abstract class Name with _$Name {
  const factory Name({required String title, required String first, required String last}) = _Name;

  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);
}

@freezed
abstract class Picture with _$Picture {
  const factory Picture({required String large, required String medium, required String thumbnail}) = _Picture;

  factory Picture.fromJson(Map<String, dynamic> json) => _$PictureFromJson(json);
}
