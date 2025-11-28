import 'package:sandwich_shop/models/sandwich.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sandwich Model', () {
    test('creates a sandwich with correct properties', () {
      final sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.wheat,
      );

      expect(sandwich.name, 'Veggie Delight');
      expect(sandwich.image, 'assets/images/veggieDelight_footlong.png');
      expect(sandwich.breadType, BreadType.wheat);
    });

    test('creates a sandwich with correct properties', () {
      final sandwich = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: true,
        breadType: BreadType.wholemeal,
      );

      expect(sandwich.name, 'Tuna Melt');
      expect(sandwich.image, 'assets/images/tunaMelt_footlong.png');
      expect(sandwich.breadType, BreadType.wholemeal);
    });
  });
}