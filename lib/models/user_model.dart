class UserModel {
  final String id;
  final String email;
  final String? nombre;
  final String? autoId;

  UserModel({
    required this.id,
    required this.email,
    this.nombre,
    this.autoId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'],
      autoId: json['auto_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'auto_id': autoId,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nombre,
    String? autoId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      autoId: autoId ?? this.autoId,
    );
  }
} 