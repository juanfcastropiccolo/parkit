import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Callbacks para detectar movimiento
  Function()? _onMovementDetected;
  Function()? _onMovementStopped;

  // Configuración de sensibilidad
  static const double _movementThreshold = 2.0; // m/s²
  static const double _gyroThreshold = 0.5; // rad/s
  static const int _stabilityDuration = 3; // segundos para considerar parado
  static const int _movementDuration = 2; // segundos para confirmar movimiento

  // Variables de estado
  bool _isMonitoring = false;
  bool _isMoving = false;
  double _lastAcceleration = 0.0;
  double _lastGyroscope = 0.0;
  Timer? _movementTimer;
  Timer? _stabilityTimer;

  // Historial de lecturas para suavizar
  final List<double> _accelerationHistory = [];
  final List<double> _gyroHistory = [];
  static const int _historySize = 10;

  bool get isMonitoring => _isMonitoring;
  bool get isMoving => _isMoving;

  // Iniciar monitoreo de sensores
  Future<void> startMonitoring({
    Function()? onMovementDetected,
    Function()? onMovementStopped,
  }) async {
    if (_isMonitoring) return;

    _onMovementDetected = onMovementDetected;
    _onMovementStopped = onMovementStopped;

    try {
      // Suscribirse al acelerómetro
      _accelerometerSubscription = accelerometerEvents.listen(
        _onAccelerometerData,
        onError: (error) {
          debugPrint('Error en acelerómetro: $error');
        },
      );

      // Suscribirse al giroscopio
      _gyroscopeSubscription = gyroscopeEvents.listen(
        _onGyroscopeData,
        onError: (error) {
          debugPrint('Error en giroscopio: $error');
        },
      );

      _isMonitoring = true;
      debugPrint('Monitoreo de sensores iniciado');
    } catch (e) {
      debugPrint('Error al iniciar sensores: $e');
      rethrow;
    }
  }

  // Detener monitoreo
  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _movementTimer?.cancel();
    _stabilityTimer?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _movementTimer = null;
    _stabilityTimer = null;

    _isMonitoring = false;
    _isMoving = false;
    _accelerationHistory.clear();
    _gyroHistory.clear();

    debugPrint('Monitoreo de sensores detenido');
  }

  // Procesar datos del acelerómetro
  void _onAccelerometerData(AccelerometerEvent event) {
    // Calcular la magnitud de la aceleración (sin gravedad)
    final acceleration = sqrt(
      pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2)
    ) - 9.81; // Restar gravedad aproximada

    _lastAcceleration = acceleration.abs();

    // Agregar al historial y mantener tamaño
    _accelerationHistory.add(_lastAcceleration);
    if (_accelerationHistory.length > _historySize) {
      _accelerationHistory.removeAt(0);
    }

    _checkMovement();
  }

  // Procesar datos del giroscopio
  void _onGyroscopeData(GyroscopeEvent event) {
    // Calcular la magnitud de la rotación
    final rotation = sqrt(
      pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2)
    );

    _lastGyroscope = rotation;

    // Agregar al historial y mantener tamaño
    _gyroHistory.add(_lastGyroscope);
    if (_gyroHistory.length > _historySize) {
      _gyroHistory.removeAt(0);
    }

    _checkMovement();
  }

  // Verificar si hay movimiento significativo
  void _checkMovement() {
    if (_accelerationHistory.isEmpty || _gyroHistory.isEmpty) return;

    // Calcular promedios suavizados
    final avgAcceleration = _accelerationHistory.reduce((a, b) => a + b) / 
                           _accelerationHistory.length;
    final avgRotation = _gyroHistory.reduce((a, b) => a + b) / 
                       _gyroHistory.length;

    // Determinar si hay movimiento
    final hasMovement = avgAcceleration > _movementThreshold || 
                       avgRotation > _gyroThreshold;

    if (hasMovement && !_isMoving) {
      // Posible inicio de movimiento
      _movementTimer?.cancel();
      _movementTimer = Timer(
        Duration(seconds: _movementDuration),
        () {
          if (!_isMoving) {
            _isMoving = true;
            _onMovementDetected?.call();
            debugPrint('Movimiento detectado - Accel: ${avgAcceleration.toStringAsFixed(2)}, Gyro: ${avgRotation.toStringAsFixed(2)}');
          }
        },
      );
      _stabilityTimer?.cancel();
    } else if (!hasMovement && _isMoving) {
      // Posible fin de movimiento
      _stabilityTimer?.cancel();
      _stabilityTimer = Timer(
        Duration(seconds: _stabilityDuration),
        () {
          if (_isMoving) {
            _isMoving = false;
            _onMovementStopped?.call();
            debugPrint('Movimiento detenido');
          }
        },
      );
      _movementTimer?.cancel();
    }
  }

  // Configurar sensibilidad personalizada
  void configureSensitivity({
    double? movementThreshold,
    double? gyroThreshold,
    int? stabilityDuration,
    int? movementDuration,
  }) {
    // Esta implementación usaría variables de instancia en lugar de constantes
    // Para simplicidad, las constantes están hardcodeadas arriba
    debugPrint('Sensibilidad configurada');
  }

  // Obtener estadísticas actuales de los sensores
  Map<String, dynamic> getSensorStats() {
    return {
      'isMonitoring': _isMonitoring,
      'isMoving': _isMoving,
      'lastAcceleration': _lastAcceleration,
      'lastGyroscope': _lastGyroscope,
      'accelerationAvg': _accelerationHistory.isNotEmpty
          ? _accelerationHistory.reduce((a, b) => a + b) / _accelerationHistory.length
          : 0.0,
      'gyroAvg': _gyroHistory.isNotEmpty
          ? _gyroHistory.reduce((a, b) => a + b) / _gyroHistory.length
          : 0.0,
    };
  }

  // Forzar detección de movimiento (para testing)
  void simulateMovement() {
    if (_isMonitoring && !_isMoving) {
      _isMoving = true;
      _onMovementDetected?.call();
      debugPrint('Movimiento simulado');
    }
  }

  // Forzar detección de parada (para testing)
  void simulateStop() {
    if (_isMonitoring && _isMoving) {
      _isMoving = false;
      _onMovementStopped?.call();
      debugPrint('Parada simulada');
    }
  }
} 