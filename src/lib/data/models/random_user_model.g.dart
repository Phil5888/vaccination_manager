// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RandomUser _$RandomUserFromJson(Map<String, dynamic> json) => _RandomUser(
  name: Name.fromJson(json['name'] as Map<String, dynamic>),
  gender: json['gender'] as String,
  email: json['email'] as String,
  picture: Picture.fromJson(json['picture'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RandomUserToJson(_RandomUser instance) =>
    <String, dynamic>{
      'name': instance.name,
      'gender': instance.gender,
      'email': instance.email,
      'picture': instance.picture,
    };

_Name _$NameFromJson(Map<String, dynamic> json) => _Name(
  title: json['title'] as String,
  first: json['first'] as String,
  last: json['last'] as String,
);

Map<String, dynamic> _$NameToJson(_Name instance) => <String, dynamic>{
  'title': instance.title,
  'first': instance.first,
  'last': instance.last,
};

_Picture _$PictureFromJson(Map<String, dynamic> json) => _Picture(
  large: json['large'] as String,
  medium: json['medium'] as String,
  thumbnail: json['thumbnail'] as String,
);

Map<String, dynamic> _$PictureToJson(_Picture instance) => <String, dynamic>{
  'large': instance.large,
  'medium': instance.medium,
  'thumbnail': instance.thumbnail,
};
