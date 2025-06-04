import 'package:flutter_test/flutter_test.dart';
import 'package:parkit_app/services/sensor_service.dart';

void main() {
  test('configureSensitivity updates values', () {
    final service = SensorService();

    final defaultMovement = service.movementThreshold;
    final defaultGyro = service.gyroThreshold;
    final defaultStability = service.stabilityDuration;
    final defaultMovementDuration = service.movementDuration;

    service.configureSensitivity(
      movementThreshold: 3.0,
      gyroThreshold: 1.0,
      stabilityDuration: 5,
      movementDuration: 4,
    );

    expect(service.movementThreshold, 3.0);
    expect(service.gyroThreshold, 1.0);
    expect(service.stabilityDuration, 5);
    expect(service.movementDuration, 4);

    // restore defaults so other tests are unaffected
    service.configureSensitivity(
      movementThreshold: defaultMovement,
      gyroThreshold: defaultGyro,
      stabilityDuration: defaultStability,
      movementDuration: defaultMovementDuration,
    );
  });
}
