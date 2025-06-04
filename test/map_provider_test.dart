import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:parkit_app/providers/map_provider.dart';
import 'package:parkit_app/services/estacionamiento_service.dart';
import 'package:parkit_app/models/estacionamiento_model.dart';

class FakeEstacionamientoService extends EstacionamientoService {
  final StreamController<List<EstacionamientoModel>> controller =
      StreamController<List<EstacionamientoModel>>.broadcast();
  int listenerCount = 0;

  FakeEstacionamientoService() {
    controller
      ..onListen = () => listenerCount++
      ..onCancel = () => listenerCount--;
  }

  @override
  Stream<List<EstacionamientoModel>> get lugaresLibresStream => controller.stream;

  @override
  Future<List<EstacionamientoModel>> getLugaresLibres() async => [];

  @override
  Future<EstacionamientoModel?> getLugarOcupadoUsuario() async => null;
}

void main() {
  test('refresh does not accumulate stream subscriptions', () async {
    final fakeService = FakeEstacionamientoService();
    final provider = MapProvider(estacionamientoService: fakeService);

    await provider.initializeMap();
    expect(fakeService.listenerCount, 1);

    await provider.refresh();
    expect(fakeService.listenerCount, 1);

    await provider.dispose();
  });
}
