import 'package:central_tower/game/state/shield_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShieldController', () {
    late ShieldController shield;

    setUp(() {
      shield = ShieldController(maxDuration: 0.5, cooldownDuration: 1);
    });

    test('automatically lowers after half a second', () {
      expect(shield.tryActivate(), isTrue);

      shield.update(0.49);
      expect(shield.isActive, isTrue);

      shield.update(0.01);
      expect(shield.isActive, isFalse);
      expect(shield.cooldownRemaining, 1);
    });

    test('cannot reactivate until one second cooldown passes', () {
      shield.tryActivate();
      shield.lower();

      expect(shield.tryActivate(), isFalse);
      shield.update(0.99);
      expect(shield.tryActivate(), isFalse);
      shield.update(0.01);
      expect(shield.tryActivate(), isTrue);
    });

    test('manual lowering also starts cooldown', () {
      shield.tryActivate();
      shield.update(0.2);
      shield.lower();

      expect(shield.isActive, isFalse);
      expect(shield.cooldownRemaining, 1);
    });
  });
}
