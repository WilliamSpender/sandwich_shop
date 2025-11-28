
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';


class Cart {
  List<Sandwich> sandwiches = List<Sandwich>.empty(growable: true);
  String notes = '';

  void addSandwich(Sandwich sandwich) {
    sandwiches.add(sandwich);
  }

  void addNote(String note) {
    notes = '$notes\n$note';
  }

  void clearCart() {
    sandwiches.clear();
    notes = '';
  }

  double calculatePriceForCart({required List<Sandwich> sandwiches}) {
    double price = 0;
    for (Sandwich sandwich in sandwiches) {
      price += PricingRepository().calculatePrice(quantity: 1, isFootlong: sandwich.isFootlong);
    }
    return price;
  }
}