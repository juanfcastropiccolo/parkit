import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/map_provider.dart';
import '../providers/auth_provider.dart';
import '../services/auto_service.dart';
import '../models/auto_model.dart';
import '../models/estacionamiento_model.dart';
import '../models/publicidad_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapProvider _mapProv;
  late final AutoService _autoService;
  AutoModel? _userAuto;
  bool _loadingAuto = true;

  @override
  void initState() {
    super.initState();
    _mapProv = Provider.of<MapProvider>(context, listen: false);
    _autoService = AutoService();
    _prepare();
  }

  Future<void> _prepare() async {
    // Load current user's auto for parking
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final autoId = authProv.currentUser?.autoId;
    if (autoId != null) {
      _userAuto = await _autoService.getAutoPorId(autoId);
    }
    setState(() => _loadingAuto = false);
    // Initialize map: ask permissions, get location, load markers
    await _mapProv.initializeMap();
  }

  void _onLibreTap(EstacionamientoModel lugar) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lugar libre',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Dimensiones: ${lugar.dimensionesTexto}'),
            const SizedBox(height: 12),
            if (_userAuto != null) ...[
              Text('Tu auto: ${_userAuto!.marca} ${_userAuto!.modelo}'),
              const SizedBox(height: 8),
              Text(_userAuto!.cabeEn(lugar.largoCm, lugar.anchoCm)
                  ? 'Tu auto cabe en este lugar.'
                  : 'Tu auto NO cabe en este lugar.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _userAuto!.cabeEn(lugar.largoCm, lugar.anchoCm)
                    ? () async {
                        Navigator.of(context).pop();
                        await _mapProv.compartirLugarOcupado(_userAuto!);
                      }
                    : null,
                child: const Text('¡Me estacioné aquí!'),
              ),
            ] else ...[
              Text('Configura tu vehículo en perfil para reclamar lugares.'),
            ],
          ],
        ),
      ),
    );
  }

  void _onPubTap(PublicidadModel pub) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(pub.marca),
        content: Text(pub.texto),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('parkit')),
      body: Consumer<MapProvider>(builder: (context, prov, _) {
        if (prov.isLoading || _loadingAuto) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prov.error != null) {
          return Center(child: Text('Error: ${prov.error}'));
        }
        final position = prov.currentPosition;
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(position!.latitude, position.longitude), zoom: 16),
          myLocationEnabled: true,
          markers: {
            for (final lugar in prov.lugaresLibres)
              Marker(
                markerId: MarkerId('libre_${lugar.id}'),
                position: LatLng(lugar.lat, lugar.lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                onTap: () => _onLibreTap(lugar),
              ),
            for (final pub in prov.publicidades)
              Marker(
                markerId: MarkerId('pub_${pub.id}'),
                position: LatLng(pub.lat, pub.lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                onTap: () => _onPubTap(pub),
              ),
            if (prov.lugarOcupadoUsuario != null)
              Marker(
                markerId: const MarkerId('mi_auto'),
                position: LatLng(prov.lugarOcupadoUsuario!.lat,
                    prov.lugarOcupadoUsuario!.lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
          },
          onMapCreated: prov.onMapCreated,
        );
      }),
      floatingActionButton: Consumer<MapProvider>(
        builder: (context, prov, _) => FloatingActionButton.extended(
          onPressed: prov.hasUserParkedCar || _userAuto == null
              ? null
              : () => prov.compartirLugarOcupado(_userAuto!),
          label: Text(prov.hasUserParkedCar ? 'En seguimiento' : 'Estacionarme'),
          icon: const Icon(Icons.local_parking),
        ),
      ),
    );
  }
}