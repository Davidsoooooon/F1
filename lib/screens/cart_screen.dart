import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopState = ShopScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: shopState.cartItems.isEmpty
          ? _EmptyCart(onBrowse: () => Navigator.of(context).pop())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...shopState.cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CartItemCard(item: item),
                  ),
                ),
                _CartSummary(
                  subtotal: shopState.cartTotal,
                  onCheckout: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checkout is a prototype action.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              'Your cart is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add merch to keep your race weekend ready.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onBrowse,
              child: const Text('Browse Shop'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shopState = ShopScope.of(context);
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.lightCard(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                product.imageAsset ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFFE5E7EB));
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.teamName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lightMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () =>
                    shopState.updateQuantity(product.id, item.quantity - 1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                item.quantity.toString(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText,
                ),
              ),
              IconButton(
                onPressed: () =>
                    shopState.updateQuantity(product.id, item.quantity + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.subtotal, required this.onCheckout});

  final double subtotal;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shipping = subtotal == 0 ? 0.0 : 7.5;
    final total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.lightCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal', value: subtotal),
          _SummaryRow(label: 'Shipping', value: shipping),
          const Divider(height: 24),
          _SummaryRow(label: 'Total', value: total, isTotal: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isTotal ? AppColors.lightText : AppColors.lightMuted,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
