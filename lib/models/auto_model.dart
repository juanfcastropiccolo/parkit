class AutoModel {
  final String id;
  final String make;
  final String model;
  final int? anio;
  final int lengthCm;
  final int widthCm;
  final int? altoCm;
  final String userId;
  final String patente;

  AutoModel({
    required this.id,
    required this.make,
    required this.model,
    this.anio,
    required this.lengthCm,
    required this.widthCm,
    this.altoCm,
    required this.userId,
    required this.patente,
  });

  factory AutoModel.fromJson(Map<String, dynamic> json) {
    return AutoModel(
      id: json['id'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      anio: json['anio'],
      lengthCm: json['length_cm'] ?? 0,
      widthCm: json['width_cm'] ?? 0,
      altoCm: json['alto_cm'],
      userId: json['user_id'] ?? '',
      patente: json['plate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'anio': anio,
      'length_cm': lengthCm,
      'width_cm': widthCm,
      'alto_cm': altoCm,
      'user_id': userId,
      'plate': patente,
    };
  }

  AutoModel copyWith({
    String? id,
    String? make,
    String? model,
    int? anio,
    int? lengthCm,
    int? widthCm,
    int? altoCm,
    String? userId,
    String? patente,
  }) {
    return AutoModel(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      anio: anio ?? this.anio,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      altoCm: altoCm ?? this.altoCm,
      userId: userId ?? this.userId,
      patente: patente ?? this.patente,
    );
  }

  // Método para verificar si un auto cabe en un espacio
  bool cabeEn(int largoEspacio, int anchoEspacio, {int margenCm = 10}) {
    return lengthCm <= (largoEspacio - margenCm) &&
           widthCm <= (anchoEspacio - margenCm);
  }

  String get dimensionesTexto => '${lengthCm}cm x ${widthCm}cm';
} 