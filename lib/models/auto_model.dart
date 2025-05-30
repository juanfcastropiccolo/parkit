class AutoModel {
  final String id;
  final String marca;
  final String modelo;
  final int? anio;
  final int largoCm;
  final int anchoCm;
  final int? altoCm;

  AutoModel({
    required this.id,
    required this.marca,
    required this.modelo,
    this.anio,
    required this.largoCm,
    required this.anchoCm,
    this.altoCm,
  });

  factory AutoModel.fromJson(Map<String, dynamic> json) {
    return AutoModel(
      id: json['id'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anio: json['anio'],
      largoCm: json['largo_cm'] ?? 0,
      anchoCm: json['ancho_cm'] ?? 0,
      altoCm: json['alto_cm'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'largo_cm': largoCm,
      'ancho_cm': anchoCm,
      'alto_cm': altoCm,
    };
  }

  AutoModel copyWith({
    String? id,
    String? marca,
    String? modelo,
    int? anio,
    int? largoCm,
    int? anchoCm,
    int? altoCm,
  }) {
    return AutoModel(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      largoCm: largoCm ?? this.largoCm,
      anchoCm: anchoCm ?? this.anchoCm,
      altoCm: altoCm ?? this.altoCm,
    );
  }

  // Método para verificar si un auto cabe en un espacio
  bool cabeEn(int largoEspacio, int anchoEspacio, {int margenCm = 10}) {
    return largoCm <= (largoEspacio - margenCm) && 
           anchoCm <= (anchoEspacio - margenCm);
  }

  String get dimensionesTexto => '${largoCm}cm x ${anchoCm}cm';
} 