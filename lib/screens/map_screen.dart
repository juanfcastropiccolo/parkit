import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/map_provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    // Initialize map when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initializeMap();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          return Stack(
            children: [
              // Google Map with full interactivity
              GoogleMap(
                onMapCreated: mapProvider.onMapCreated,
                markers: mapProvider.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // We'll use custom button
                zoomGesturesEnabled: true, // ✅ Pinch to zoom
                scrollGesturesEnabled: true, // ✅ Pan with fingers
                rotateGesturesEnabled: true, // ✅ Rotate with two fingers
                tiltGesturesEnabled: true, // ✅ Tilt gesture
                zoomControlsEnabled: false, // Hide default zoom buttons
                mapToolbarEnabled: false, // Hide default toolbar
                compassEnabled: true, // Show compass
                trafficEnabled: false, // Hide traffic by default
                mapType: MapType.normal, // Can be changed to satellite, hybrid, etc.
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    mapProvider.currentPosition?.latitude ?? -34.6118,
                    mapProvider.currentPosition?.longitude ?? -58.3960,
                  ),
                  zoom: 15.0,
                ),
                // Handle map gestures
                onTap: _onMapTapped,
                onLongPress: _onMapLongPressed,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
              ),

              // Search bar overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: _buildSearchBar(context, mapProvider),
              ),

              // My Location button
              Positioned(
                bottom: 120,
                right: 16,
                child: _buildMyLocationButton(mapProvider),
              ),

              // Zoom controls
              Positioned(
                bottom: 200,
                right: 16,
                child: _buildZoomControls(mapProvider),
              ),

              // Map type toggle
              Positioned(
                bottom: 120,
                left: 16,
                child: _buildMapTypeButton(),
              ),

              // Loading indicator
              if (mapProvider.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Error message
              if (mapProvider.error != null)
                Positioned(
                  bottom: 80,
                  left: 16,
                  right: 16,
                  child: _buildErrorCard(mapProvider),
                ),
            ],
          );
        },
      ),
      // Floating action button for sharing parking
      floatingActionButton: _buildShareParkingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSearchBar(BuildContext context, MapProvider mapProvider) {
    return Card(
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar dirección...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showSearchResults = false;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            mapProvider.searchAndGoToAddress(value);
            FocusScope.of(context).unfocus();
          }
        },
        onChanged: (value) {
          setState(() {
            _showSearchResults = value.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildMyLocationButton(MapProvider mapProvider) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primaryCeleste,
      onPressed: () {
        mapProvider.initializeMap(); // This will move to current location
      },
      child: const Icon(Icons.my_location),
    );
  }

  Widget _buildZoomControls(MapProvider mapProvider) {
    return Column(
      children: [
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryCeleste,
          onPressed: () => _zoomIn(mapProvider),
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryCeleste,
          onPressed: () => _zoomOut(mapProvider),
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }

  Widget _buildMapTypeButton() {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primaryCeleste,
      onPressed: _showMapTypeDialog,
      child: const Icon(Icons.layers),
    );
  }

  Widget _buildErrorCard(MapProvider mapProvider) {
    return Card(
      color: Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mapProvider.error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => mapProvider.clearError(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareParkingButton() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        if (mapProvider.hasUserParkedCar) {
          return FloatingActionButton.extended(
            onPressed: () => _showReleaseParkingDialog(mapProvider),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.directions_car),
            label: const Text('Liberar lugar'),
          );
        } else {
          return FloatingActionButton.extended(
            onPressed: () => _showShareParkingDialog(mapProvider),
            icon: const Icon(Icons.add_location),
            label: const Text('Compartir lugar'),
          );
        }
      },
    );
  }

  // Map event handlers
  void _onMapTapped(LatLng position) {
    print('Map tapped at: ${position.latitude}, ${position.longitude}');
    FocusScope.of(context).unfocus(); // Hide keyboard if open
  }

  void _onMapLongPressed(LatLng position) {
    print('Map long pressed at: ${position.latitude}, ${position.longitude}');
    _showAddParkingDialog(position);
  }

  void _onCameraMove(CameraPosition position) {
    // Called while user is moving the map
    // You can implement logic here if needed (e.g., loading nearby spots)
  }

  void _onCameraIdle() {
    // Called when map movement stops
    // Good place to load new data based on visible area
    print('Camera movement stopped');
  }

  // Zoom functions
  void _zoomIn(MapProvider mapProvider) {
    mapProvider.mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut(MapProvider mapProvider) {
    mapProvider.mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  // Dialog functions
  void _showMapTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tipo de mapa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Normal'),
              onTap: () => _changeMapType(MapType.normal),
            ),
            ListTile(
              title: const Text('Satélite'),
              onTap: () => _changeMapType(MapType.satellite),
            ),
            ListTile(
              title: const Text('Híbrido'),
              onTap: () => _changeMapType(MapType.hybrid),
            ),
            ListTile(
              title: const Text('Terreno'),
              onTap: () => _changeMapType(MapType.terrain),
            ),
          ],
        ),
      ),
    );
  }

  void _changeMapType(MapType mapType) {
    Navigator.pop(context);
    // You would implement this in MapProvider
    print('Changing map type to: $mapType');
  }

  void _showShareParkingDialog(MapProvider mapProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir lugar de estacionamiento'),
        content: const Text('¿Quieres compartir tu lugar actual de estacionamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // You would call mapProvider.compartirLugarOcupado() here
              // Need to get user's car info first
              print('Sharing parking spot');
            },
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
  }

  void _showReleaseParkingDialog(MapProvider mapProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liberar lugar'),
        content: const Text('¿Confirmás que dejaste el lugar de estacionamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              mapProvider.confirmarLugarLibre();
            },
            child: const Text('Sí, liberar'),
          ),
        ],
      ),
    );
  }

  void _showAddParkingDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar lugar de estacionamiento'),
        content: Text(
          'Coordenadas: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}\n\n'
          '¿Quieres marcar este lugar como disponible?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              print('Adding parking at: $position');
              // Implement adding parking logic
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
} 