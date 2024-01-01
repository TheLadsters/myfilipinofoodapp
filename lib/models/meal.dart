class Meal {
  const Meal(
      {this.id,
      required this.name,
      required this.ingredients,
      required this.imgUrl,
      required this.instructions});

  final String? id;
  final String name;
  final List<String> ingredients;
  final String imgUrl;
  final String instructions;
}
