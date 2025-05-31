class UserModel {
  final String id;
  final String email;
  final String? nombre;
  final String? autoId;
  final String? telefono;

  UserModel({
    required this.id,
    required this.email,
    this.nombre,
    this.autoId,
    this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'],
      autoId: json['auto_id'],
      telefono: json['telefono'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'auto_id': autoId,
      'telefono': telefono,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nombre,
    String? autoId,
    String? telefono,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      autoId: autoId ?? this.autoId,
      telefono: telefono ?? this.telefono,
    );
  }
} 