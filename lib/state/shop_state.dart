import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/products_data.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class ShopState extends ChangeNotifier {
  static const _cartKey = 'shop.cart.v1';
  static const _favoritesKey = 'shop.favorites.v1';

  final Map<String, CartItem> _cart = {};
  final Set<String> _favorites = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<CartItem> get cartItems {
    final items = _cart.values.toList();
    items.sort((a, b) => a.product.name.compareTo(b.product.name));
    return items;
  }

  int get cartCount => _cart.values.fold(0, (sum, item) => sum + item.quantity);

  int get favoriteCount => _favorites.length;

  double get cartTotal =>
      _cart.values.fold(0, (sum, item) => sum + item.subtotal);

  bool get hasItems => _cart.isNotEmpty;

  bool isFavorite(String productId) => _favorites.contains(productId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites
      ..clear()
      ..addAll(prefs.getStringList(_favoritesKey) ?? const []);

    _cart.clear();
    for (final encoded in prefs.getStringList(_cartKey) ?? const []) {
      final parts = encoded.split(':');
      if (parts.length != 2) continue;
      final product = _productById(parts.first);
      final quantity = int.tryParse(parts.last);
      if (product == null || quantity == null || quantity <= 0) continue;
      _cart[product.id] = CartItem(product: product, quantity: quantity);
    }

    _isLoaded = true;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    _saveFavorites();
    notifyListeners();
  }

  void addToCart(Product product) {
    final existing = _cart[product.id];
    if (existing == null) {
      _cart[product.id] = CartItem(product: product, quantity: 1);
    } else {
      existing.quantity += 1;
    }
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_cart.containsKey(productId)) return;
    if (quantity <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId]!.quantity = quantity;
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    if (_cart.remove(productId) != null) {
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _saveCart();
    notifyListeners();
  }

  Product? _productById(String id) {
    for (final product in productsData) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _cart.values
        .map((item) => '${item.product.id}:${item.quantity}')
        .toList();
    await prefs.setStringList(_cartKey, encoded);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites.toList()..sort());
  }
}

class ShopScope extends InheritedNotifier<ShopState> {
  const ShopScope({
    super.key,
    required ShopState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ShopState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShopScope>();
    assert(scope != null, 'ShopScope not found in widget tree');
    return scope!.notifier!;
  }
}
