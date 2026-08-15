import 'package:flutter/material.dart';

import '../data/products_data.dart';
import '../data/teams_data.dart';
import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _searchQuery = '';
  String _selectedTeamId = 'all';
  String _selectedCategory = 'all';
  bool _favoritesOnly = false;

  List<String> get _categories {
    final set = <String>{};
    for (final product in productsData) {
      set.add(product.category);
    }
    final list = set.toList()..sort();
    list.insert(0, 'all');
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shopState = ShopScope.of(context);

    final filtered = productsData.where((product) {
      if (_selectedTeamId != 'all' && product.teamId != _selectedTeamId) {
        return false;
      }
      if (_selectedCategory != 'all' && product.category != _selectedCategory) {
        return false;
      }
      if (_favoritesOnly && !shopState.isFavorite(product.id)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(query) &&
            !product.teamName.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          CartIconButton(
            count: shopState.cartCount,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.heroGradient(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'F1 Team Merch',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Official-inspired gear for every 2026 team.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _HeroStat(label: 'Teams', value: '11'),
                    _HeroStat(label: 'Categories', value: '4'),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroStat(
                      label: 'In Cart',
                      value: shopState.cartCount.toString(),
                    ),
                    _HeroStat(
                      label: 'Saved',
                      value: shopState.favoriteCount.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
            decoration: InputDecoration(
              hintText: 'Search merch, teams, or categories',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1C1C1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE10600)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Teams',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedTeamId == 'all',
                    onSelected: (_) => setState(() => _selectedTeamId = 'all'),
                  ),
                ),
                ...teamsData.map(
                  (team) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(team.name),
                      selected: _selectedTeamId == team.id,
                      selectedColor: team.color.withAlpha(30),
                      onSelected: (_) =>
                          setState(() => _selectedTeamId = team.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Categories',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              FilterChip(
                label: const Text('Favorites'),
                selected: _favoritesOnly,
                onSelected: (value) => setState(() => _favoritesOnly = value),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category == 'all' ? 'All' : category),
                        selected: _selectedCategory == category,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.darkCard(radius: 14),
              child: Column(
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.white38),
                  const SizedBox(height: 12),
                  Text(
                    'No merch found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try another team or category filter.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.64,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final product = filtered[index];
                return ProductCard(
                  product: product,
                  isFavorite: shopState.isFavorite(product.id),
                  onFavorite: () => shopState.toggleFavorite(product.id),
                  onAdd: () {
                    shopState.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onTap: () => _openProduct(context, product),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
