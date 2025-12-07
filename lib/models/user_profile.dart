class UserProfile {
  final String? name;
  final String? email;
  final String? avatar;
  final String? height;
  final String? weight;
  final String? birthDate;
  final String? gender;

  UserProfile({
    this.name,
    this.email,
    this.avatar,
    this.height,
    this.weight,
    this.birthDate,
    this.gender,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String?,
      email: map['email'] as String?,
      avatar: map['avatar'] as String?,
      height: map['height'] as String?,
      weight: map['weight'] as String?,
      birthDate: map['birthDate'] as String?,
      gender: map['gender'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (avatar != null) 'avatar': avatar,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (birthDate != null) 'birthDate': birthDate,
      if (gender != null) 'gender': gender,
    };
  }
}
