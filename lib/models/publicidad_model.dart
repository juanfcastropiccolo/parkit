class PublicidadModel {
  final String id;
  final String marca;
  final double lat;
  final double lng;
  final String texto;
  final String url;
  final bool activo;

  PublicidadModel({
    required this.id,
    required this.marca,
    required this.lat,
    required this.lng,
    required this.texto,
    required this.url,
    this.activo = true,
  });

  factory PublicidadModel.fromJson(Map<String, dynamic> json) {
    return PublicidadModel(
      id: json['id'] ?? '',
      marca: json['marca'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      texto: json['texto'] ?? '',
      url: json['url'] ?? '',
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'lat': lat,
      'lng': lng,
      'texto': texto,
      'url': url,
      'activo': activo,
    };
  }

  PublicidadModel copyWith({
    String? id,
    String? marca,
    double? lat,
    double? lng,
    String? texto,
    String? url,
    bool? activo,
  }) {
    return PublicidadModel(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      texto: texto ?? this.texto,
      url: url ?? this.url,
      activo: activo ?? this.activo,
    );
  }
} 