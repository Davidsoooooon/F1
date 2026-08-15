import 'product.dart';

class CartItem {
  CartItem({required this.product, required this.quantity});

  final Product product;
  int quantity;

  double get subtotal => product.price * quantity;
}
