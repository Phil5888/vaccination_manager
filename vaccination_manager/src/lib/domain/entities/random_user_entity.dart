class RandomUserEntity {
  final NameEntity name;
  final String gender;
  final String email;
  final PictureEntity picture;

  const RandomUserEntity({required this.name, required this.gender, required this.email, required this.picture});

  RandomUserEntity copyWith({NameEntity? name, String? gender, String? email, PictureEntity? picture}) {
    return RandomUserEntity(name: name ?? this.name, gender: gender ?? this.gender, email: email ?? this.email, picture: picture ?? this.picture);
  }
}

class NameEntity {
  final String title;
  final String first;
  final String last;

  const NameEntity({required this.title, required this.first, required this.last});

  NameEntity copyWith({String? title, String? first, String? last}) {
    return NameEntity(title: title ?? this.title, first: first ?? this.first, last: last ?? this.last);
  }
}

class PictureEntity {
  final String large;
  final String medium;
  final String thumbnail;

  const PictureEntity({required this.large, required this.medium, required this.thumbnail});
}
