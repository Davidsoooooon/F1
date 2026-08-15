class Product {
  const Product({
    required this.id,
    required this.name,
    required this.teamId,
    required this.teamName,
    required this.category,
    required this.description,
    required this.price,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String teamId;
  final String teamName;
  final String category;
  final String description;
  final double price;
  final String? imageAsset;
}
