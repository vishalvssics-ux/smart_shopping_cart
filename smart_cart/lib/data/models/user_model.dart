class UserModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? token;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString() ?? '',
      profileImage: json['profileImage'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      token: token ?? this.token,
    );
  }
}
