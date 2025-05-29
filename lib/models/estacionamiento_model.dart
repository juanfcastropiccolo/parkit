enum EstadoEstacionamiento { libre, ocupado }

class EstacionamientoModel {
  final String id;
  final String? userId;
  final double lat;
  final double lng;
  final int largoCm;
  final int anchoCm;
  final DateTime timestamp;
  final EstadoEstacionamiento status;

  EstacionamientoModel({
    required this.id,
    this.userId,
    required this.lat,
    required this.lng,
    required this.largoCm,
    required this.anchoCm,
    required this.timestamp,
    required this.status,
  });

  factory EstacionamientoModel.fromJson(Map<String, dynamic> json) {
    return EstacionamientoModel(
      id: json['id'] ?? '',
      userId: json['user_id'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      largoCm: json['largo_cm'] ?? 0,
      anchoCm: json['ancho_cm'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: json['status'] == 'libre' 
          ? EstadoEstacionamiento.libre 
          : EstadoEstacionamiento.ocupado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lat': lat,
      'lng': lng,
      'largo_cm': largoCm,
      'ancho_cm': anchoCm,
      'timestamp': timestamp.toIso8601String(),
      'status': status == EstadoEstacionamiento.libre ? 'libre' : 'ocupado',
    };
  }

  EstacionamientoModel copyWith({
    String? id,
    String? userId,
    double? lat,
    double? lng,
    int? largoCm,
    int? anchoCm,
    DateTime? timestamp,
    EstadoEstacionamiento? status,
  }) {
    return EstacionamientoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      largoCm: largoCm ?? this.largoCm,
      anchoCm: anchoCm ?? this.anchoCm,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  String get dimensionesTexto => '${largoCm}cm x ${anchoCm}cm';
  
  bool get esLibre => status == EstadoEstacionamiento.libre;
  
  bool get esOcupado => status == EstadoEstacionamiento.ocupado;
  
  // Verificar si un auto específico cabe en este lugar
  bool puedeAcomodar(int autoLargo, int autoAncho, {int margenCm = 10}) {
    return autoLargo <= (largoCm - margenCm) && 
           autoAncho <= (anchoCm - margenCm);
  }
} 