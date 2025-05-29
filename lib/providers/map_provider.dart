import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/estacionamiento_model.dart';
import '../models/publicidad_model.dart';
import '../models/auto_model.dart';
import '../services/estacionamiento_service.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';
import '../services/notification_service.dart';
import '../services/distance_matrix_service.dart';
import '../services/geocoding_service.dart';

class MapProvider with ChangeNotifier {
  final EstacionamientoService _estacionamientoService = EstacionamientoService();
  final LocationService _locationService = LocationService();
  final SensorService _sensorService = SensorService();
  final NotificationService _notificationService = NotificationService();

  // Estado del mapa
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  // Estado de los estacionamientos
  List<EstacionamientoModel> _lugaresLibres = [];
  List<PublicidadModel> _publicidades = [];
  EstacionamientoModel? _lugarOcupadoUsuario;

  // Estado del tracking
  bool _isTrackingParking = false;
  StreamSubscription<List<EstacionamientoModel>>? _estacionamientosSubscription;

  // Getters
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EstacionamientoModel> get lugaresLibres => _lugaresLibres;
  List<PublicidadModel> get publicidades => _publicidades;
  EstacionamientoModel? get lugarOcupadoUsuario => _lugarOcupadoUsuario;
  bool get isTrackingParking => _isTrackingParking;
  bool get hasUserParkedCar => _lugarOcupadoUsuario != null;

  // Map type control
  MapType _mapType = MapType.normal;
  MapType get mapType => _mapType;

  // Inicializar el mapa
  Future<void> initializeMap() async {
    _setLoading(true);

    try {
      // Obtener ubicación actual
      await _getCurrentLocation();
      
      // Cargar lugares libres
      await _loadLugaresLibres();
      
      // Cargar publicidades
      await _loadPublicidades();
      
      // Verificar si el usuario tiene un auto estacionado
      await _checkUserParkedCar();
      
      // Configurar stream de cambios en tiempo real
      _setupRealtimeUpdates();
      
      _setLoading(false);
    } catch (e) {
      _setError('Error al inicializar el mapa: $e');
      _setLoading(false);
    }
  }

  // Configurar el controlador del mapa cuando está listo
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveToCurrentLocation();
  }

  // Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentOrDefaultLocation();
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al obtener ubicación: $e');
    }
  }

  // Mover la cámara a la ubicación actual
  void _moveToCurrentLocation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  // Cargar lugares libres
  Future<void> _loadLugaresLibres() async {
    try {
      _lugaresLibres = await _estacionamientoService.getLugaresLibres();
      _updateMarkers();
    } catch (e) {
      debugPrint('Error al cargar lugares libres: $e');
    }
  }

  // Cargar publicidades (mock)
  Future<void> _loadPublicidades() async {
    // Mock de publicidades para demo
    _publicidades = [
      PublicidadModel(
        id: '1',
        marca: 'McDonald\'s',
        lat: -34.6037,
        lng: -58.3816,
        texto: 'McDonald\'s Plaza San Martín - ¡Menú del día!',
        url: 'https://mcdonalds.com.ar',
      ),
      PublicidadModel(
        id: '2',
        marca: 'Shell',
        lat: -34.6158,
        lng: -58.3831,
        texto: 'Estación Shell - Combustible y servicios',
        url: 'https://shell.com.ar',
      ),
    ];
    _updateMarkers();
  }

  // Configurar actualizaciones en tiempo real
  void _setupRealtimeUpdates() {
    _estacionamientosSubscription = _estacionamientoService
        .lugaresLibresStream
        .listen((lugares) {
      _lugaresLibres = lugares;
      _updateMarkers();
    });
  }

  // Actualizar marcadores en el mapa
  void _updateMarkers() {
    final newMarkers = <Marker>{};

    // Agregar marcadores de lugares libres
    for (final lugar in _lugaresLibres) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('libre_${lugar.id}'),
          position: LatLng(lugar.lat, lugar.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Lugar libre',
            snippet: lugar.dimensionesTexto,
            onTap: () => _onLugarLibreTapped(lugar),
          ),
          onTap: () => _onLugarLibreTapped(lugar),
        ),
      );
    }

    // Agregar marcadores de publicidad
    for (final publicidad in _publicidades) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('pub_${publicidad.id}'),
          position: LatLng(publicidad.lat, publicidad.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: publicidad.marca,
            snippet: publicidad.texto,
          ),
          onTap: () => _onPublicidadTapped(publicidad),
        ),
      );
    }

    // Agregar marcador de ubicación del auto estacionado del usuario
    if (_lugarOcupadoUsuario != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('mi_auto'),
          position: LatLng(_lugarOcupadoUsuario!.lat, _lugarOcupadoUsuario!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Mi auto',
            snippet: 'Tu vehículo está estacionado aquí',
          ),
        ),
      );
    }

    _markers = newMarkers;
    notifyListeners();
  }

  // Manejar tap en lugar libre
  void _onLugarLibreTapped(EstacionamientoModel lugar) {
    // Esta función será llamada desde la UI para mostrar detalles
    debugPrint('Lugar libre seleccionado: ${lugar.id}');
  }

  // Manejar tap en publicidad
  void _onPublicidadTapped(PublicidadModel publicidad) {
    debugPrint('Publicidad seleccionada: ${publicidad.marca}');
    // Aquí se podría abrir la URL o mostrar más detalles
  }

  // Compartir lugar ocupado
  Future<bool> compartirLugarOcupado(AutoModel auto) async {
    if (_currentPosition == null) {
      _setError('No se pudo obtener la ubicación actual');
      return false;
    }

    _setLoading(true);

    try {
      final lugarOcupado = await _estacionamientoService.compartirLugarOcupado(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        auto: auto,
      );

      _lugarOcupadoUsuario = lugarOcupado;
      _updateMarkers();

      // Iniciar tracking de movimiento
      await _startParkingTracking();

      // Mostrar notificación de éxito
      await _notificationService.showLugarCompartidoNotification();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al compartir lugar: $e');
      _setLoading(false);
      return false;
    }
  }

  // Iniciar tracking de estacionamiento
  Future<void> _startParkingTracking() async {
    if (_isTrackingParking) return;

    _isTrackingParking = true;
    notifyListeners();

    await _sensorService.startMonitoring(
      onMovementDetected: _onMovementDetected,
      onMovementStopped: _onMovementStopped,
    );
  }

  // Detener tracking de estacionamiento
  void _stopParkingTracking() {
    _isTrackingParking = false;
    _sensorService.stopMonitoring();
    notifyListeners();
  }

  // Callback cuando se detecta movimiento
  void _onMovementDetected() async {
    debugPrint('Movimiento detectado del vehículo');
    await _notificationService.showMovementDetectedNotification();
  }

  // Callback cuando se detiene el movimiento
  void _onMovementStopped() {
    debugPrint('Vehículo detenido');
  }

  // Confirmar que el usuario dejó el lugar
  Future<bool> confirmarLugarLibre() async {
    if (_lugarOcupadoUsuario == null) return false;

    _setLoading(true);

    try {
      await _estacionamientoService.marcarLugarComoLibre(_lugarOcupadoUsuario!.id);
      
      _lugarOcupadoUsuario = null;
      _stopParkingTracking();
      _updateMarkers();

      // Mostrar notificación de lugar liberado
      await _notificationService.showLugarLiberadoNotification();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al liberar lugar: $e');
      _setLoading(false);
      return false;
    }
  }

  // Verificar si el usuario tiene un auto estacionado
  Future<void> _checkUserParkedCar() async {
    try {
      _lugarOcupadoUsuario = await _estacionamientoService.getLugarOcupadoUsuario();
      if (_lugarOcupadoUsuario != null) {
        await _startParkingTracking();
      }
    } catch (e) {
      debugPrint('Error al verificar auto estacionado: $e');
    }
  }

  // Filtrar lugares por auto específico
  Future<void> filtrarLugaresPorAuto(AutoModel auto) async {
    _setLoading(true);

    try {
      _lugaresLibres = await _estacionamientoService.getLugaresLibresParaAuto(auto);
      _updateMarkers();
      _setLoading(false);
    } catch (e) {
      _setError('Error al filtrar lugares: $e');
      _setLoading(false);
    }
  }

  // Recargar todos los datos
  Future<void> refresh() async {
    await initializeMap();
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _estacionamientosSubscription?.cancel();
    _sensorService.stopMonitoring();
    super.dispose();
  }

  // Load lugares ordered by distance
  Future<void> loadLugaresByDistance() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }
    
    if (_currentPosition == null) return;

    _setLoading(true);
    try {
      _lugaresLibres = await _estacionamientoService.getLugaresLibresByDistance(
        userLat: _currentPosition!.latitude,
        userLng: _currentPosition!.longitude,
      );
      _updateMarkers();
      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar lugares por distancia: $e');
      _setLoading(false);
    }
  }

  // Search for address and move map
  Future<void> searchAndGoToAddress(String address) async {
    _setLoading(true);
    try {
      final geocodingService = GeocodingService();
      final results = await geocodingService.geocodeAddress(address);
      
      if (results.isNotEmpty) {
        final location = results.first;
        
        // Move map to location
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(location.lat, location.lng),
              15.0,
            ),
          );
        }
        
        // Load nearby parking spots
        _lugaresLibres = await _estacionamientoService.getNearbyLugaresLibres(
          userLat: location.lat,
          userLng: location.lng,
        );
        _updateMarkers();
      } else {
        _setError('No se encontró la dirección');
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Error al buscar dirección: $e');
      _setLoading(false);
    }
  }

  // Get address for current position
  Future<String?> getCurrentAddress() async {
    if (_currentPosition == null) return null;
    
    try {
      final geocodingService = GeocodingService();
      final result = await geocodingService.reverseGeocode(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      return result?.formattedAddress;
    } catch (e) {
      debugPrint('Error getting current address: $e');
      return null;
    }
  }

  // Map type control
  void changeMapType(MapType newType) {
    _mapType = newType;
    notifyListeners();
  }

  // Camera controls
  Future<void> animateToPosition(double lat, double lng, {double zoom = 15.0}) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom),
      );
    }
  }

  Future<void> zoomIn() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  Future<void> zoomOut() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  // Get current camera position
  Future<CameraPosition?> getCurrentCameraPosition() async {
    if (_mapController != null) {
      return await _mapController!.getCamera();
    }
    return null;
  }
} 