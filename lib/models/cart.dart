
import 'dart:core';

import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';


class Cart {
  List<CartItem> sandwiches = List<CartItem>.empty(growable: true);
  String notes = '';

  void addSandwich({required Sandwich sandwich, required int quantity}) {
    sandwiches.add(CartItem(sandwich: sandwich, quantity: quantity));
  }

  void addNote({required String note}) {
    notes = '$notes\n$note';
  }

  void clearCart() {
    sandwiches.clear();
    notes = '';
  }

  double calculatePriceForCart() {
    double price = 0;
    for (CartItem item in sandwiches) {
      price += PricingRepository().calculatePrice(quantity: item.quantity, isFootlong: item.sandwich.isFootlong);
    }
    return price;
  }

  String summary() {
    final buffer = StringBuffer();

    if (sandwiches.isEmpty) {
      buffer.writeln('No items in cart.');
    } else {
      for (final item in sandwiches) {
        final s = item.sandwich;
        final size = s.isFootlong ? 'footlong' : 'six-inch';
        buffer.writeln('${item.quantity}  ${s.name} $size');
      }
    }

    buffer.writeln('');
    buffer.writeln('Notes: $notes');
    buffer.writeln('');
    buffer.writeln('TotalPrice: \$${calculatePriceForCart()}');

    return buffer.toString();
  }

}
class CartItem {
  final Sandwich sandwich;
  final int quantity;

  const CartItem({
    required this.sandwich,
    required this.quantity
  });
}