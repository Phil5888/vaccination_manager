// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'random_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RandomUser {

 Name get name; String get gender; String get email; Picture get picture;
/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RandomUserCopyWith<RandomUser> get copyWith => _$RandomUserCopyWithImpl<RandomUser>(this as RandomUser, _$identity);

  /// Serializes this RandomUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RandomUser&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.picture, picture) || other.picture == picture));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,gender,email,picture);

@override
String toString() {
  return 'RandomUser(name: $name, gender: $gender, email: $email, picture: $picture)';
}


}

/// @nodoc
abstract mixin class $RandomUserCopyWith<$Res>  {
  factory $RandomUserCopyWith(RandomUser value, $Res Function(RandomUser) _then) = _$RandomUserCopyWithImpl;
@useResult
$Res call({
 Name name, String gender, String email, Picture picture
});


$NameCopyWith<$Res> get name;$PictureCopyWith<$Res> get picture;

}
/// @nodoc
class _$RandomUserCopyWithImpl<$Res>
    implements $RandomUserCopyWith<$Res> {
  _$RandomUserCopyWithImpl(this._self, this._then);

  final RandomUser _self;
  final $Res Function(RandomUser) _then;

/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? gender = null,Object? email = null,Object? picture = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as Name,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,picture: null == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as Picture,
  ));
}
/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NameCopyWith<$Res> get name {
  
  return $NameCopyWith<$Res>(_self.name, (value) {
    return _then(_self.copyWith(name: value));
  });
}/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PictureCopyWith<$Res> get picture {
  
  return $PictureCopyWith<$Res>(_self.picture, (value) {
    return _then(_self.copyWith(picture: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _RandomUser implements RandomUser {
  const _RandomUser({required this.name, required this.gender, required this.email, required this.picture});
  factory _RandomUser.fromJson(Map<String, dynamic> json) => _$RandomUserFromJson(json);

@override final  Name name;
@override final  String gender;
@override final  String email;
@override final  Picture picture;

/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RandomUserCopyWith<_RandomUser> get copyWith => __$RandomUserCopyWithImpl<_RandomUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RandomUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RandomUser&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.picture, picture) || other.picture == picture));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,gender,email,picture);

@override
String toString() {
  return 'RandomUser(name: $name, gender: $gender, email: $email, picture: $picture)';
}


}

/// @nodoc
abstract mixin class _$RandomUserCopyWith<$Res> implements $RandomUserCopyWith<$Res> {
  factory _$RandomUserCopyWith(_RandomUser value, $Res Function(_RandomUser) _then) = __$RandomUserCopyWithImpl;
@override @useResult
$Res call({
 Name name, String gender, String email, Picture picture
});


@override $NameCopyWith<$Res> get name;@override $PictureCopyWith<$Res> get picture;

}
/// @nodoc
class __$RandomUserCopyWithImpl<$Res>
    implements _$RandomUserCopyWith<$Res> {
  __$RandomUserCopyWithImpl(this._self, this._then);

  final _RandomUser _self;
  final $Res Function(_RandomUser) _then;

/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? gender = null,Object? email = null,Object? picture = null,}) {
  return _then(_RandomUser(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as Name,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,picture: null == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as Picture,
  ));
}

/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NameCopyWith<$Res> get name {
  
  return $NameCopyWith<$Res>(_self.name, (value) {
    return _then(_self.copyWith(name: value));
  });
}/// Create a copy of RandomUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PictureCopyWith<$Res> get picture {
  
  return $PictureCopyWith<$Res>(_self.picture, (value) {
    return _then(_self.copyWith(picture: value));
  });
}
}


/// @nodoc
mixin _$Name {

 String get title; String get first; String get last;
/// Create a copy of Name
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NameCopyWith<Name> get copyWith => _$NameCopyWithImpl<Name>(this as Name, _$identity);

  /// Serializes this Name to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Name&&(identical(other.title, title) || other.title == title)&&(identical(other.first, first) || other.first == first)&&(identical(other.last, last) || other.last == last));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,first,last);

@override
String toString() {
  return 'Name(title: $title, first: $first, last: $last)';
}


}

/// @nodoc
abstract mixin class $NameCopyWith<$Res>  {
  factory $NameCopyWith(Name value, $Res Function(Name) _then) = _$NameCopyWithImpl;
@useResult
$Res call({
 String title, String first, String last
});




}
/// @nodoc
class _$NameCopyWithImpl<$Res>
    implements $NameCopyWith<$Res> {
  _$NameCopyWithImpl(this._self, this._then);

  final Name _self;
  final $Res Function(Name) _then;

/// Create a copy of Name
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? first = null,Object? last = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,first: null == first ? _self.first : first // ignore: cast_nullable_to_non_nullable
as String,last: null == last ? _self.last : last // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Name implements Name {
  const _Name({required this.title, required this.first, required this.last});
  factory _Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);

@override final  String title;
@override final  String first;
@override final  String last;

/// Create a copy of Name
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NameCopyWith<_Name> get copyWith => __$NameCopyWithImpl<_Name>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Name&&(identical(other.title, title) || other.title == title)&&(identical(other.first, first) || other.first == first)&&(identical(other.last, last) || other.last == last));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,first,last);

@override
String toString() {
  return 'Name(title: $title, first: $first, last: $last)';
}


}

/// @nodoc
abstract mixin class _$NameCopyWith<$Res> implements $NameCopyWith<$Res> {
  factory _$NameCopyWith(_Name value, $Res Function(_Name) _then) = __$NameCopyWithImpl;
@override @useResult
$Res call({
 String title, String first, String last
});




}
/// @nodoc
class __$NameCopyWithImpl<$Res>
    implements _$NameCopyWith<$Res> {
  __$NameCopyWithImpl(this._self, this._then);

  final _Name _self;
  final $Res Function(_Name) _then;

/// Create a copy of Name
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? first = null,Object? last = null,}) {
  return _then(_Name(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,first: null == first ? _self.first : first // ignore: cast_nullable_to_non_nullable
as String,last: null == last ? _self.last : last // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Picture {

 String get large; String get medium; String get thumbnail;
/// Create a copy of Picture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PictureCopyWith<Picture> get copyWith => _$PictureCopyWithImpl<Picture>(this as Picture, _$identity);

  /// Serializes this Picture to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Picture&&(identical(other.large, large) || other.large == large)&&(identical(other.medium, medium) || other.medium == medium)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,large,medium,thumbnail);

@override
String toString() {
  return 'Picture(large: $large, medium: $medium, thumbnail: $thumbnail)';
}


}

/// @nodoc
abstract mixin class $PictureCopyWith<$Res>  {
  factory $PictureCopyWith(Picture value, $Res Function(Picture) _then) = _$PictureCopyWithImpl;
@useResult
$Res call({
 String large, String medium, String thumbnail
});




}
/// @nodoc
class _$PictureCopyWithImpl<$Res>
    implements $PictureCopyWith<$Res> {
  _$PictureCopyWithImpl(this._self, this._then);

  final Picture _self;
  final $Res Function(Picture) _then;

/// Create a copy of Picture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? large = null,Object? medium = null,Object? thumbnail = null,}) {
  return _then(_self.copyWith(
large: null == large ? _self.large : large // ignore: cast_nullable_to_non_nullable
as String,medium: null == medium ? _self.medium : medium // ignore: cast_nullable_to_non_nullable
as String,thumbnail: null == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Picture implements Picture {
  const _Picture({required this.large, required this.medium, required this.thumbnail});
  factory _Picture.fromJson(Map<String, dynamic> json) => _$PictureFromJson(json);

@override final  String large;
@override final  String medium;
@override final  String thumbnail;

/// Create a copy of Picture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PictureCopyWith<_Picture> get copyWith => __$PictureCopyWithImpl<_Picture>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PictureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Picture&&(identical(other.large, large) || other.large == large)&&(identical(other.medium, medium) || other.medium == medium)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,large,medium,thumbnail);

@override
String toString() {
  return 'Picture(large: $large, medium: $medium, thumbnail: $thumbnail)';
}


}

/// @nodoc
abstract mixin class _$PictureCopyWith<$Res> implements $PictureCopyWith<$Res> {
  factory _$PictureCopyWith(_Picture value, $Res Function(_Picture) _then) = __$PictureCopyWithImpl;
@override @useResult
$Res call({
 String large, String medium, String thumbnail
});




}
/// @nodoc
class __$PictureCopyWithImpl<$Res>
    implements _$PictureCopyWith<$Res> {
  __$PictureCopyWithImpl(this._self, this._then);

  final _Picture _self;
  final $Res Function(_Picture) _then;

/// Create a copy of Picture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? large = null,Object? medium = null,Object? thumbnail = null,}) {
  return _then(_Picture(
large: null == large ? _self.large : large // ignore: cast_nullable_to_non_nullable
as String,medium: null == medium ? _self.medium : medium // ignore: cast_nullable_to_non_nullable
as String,thumbnail: null == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
