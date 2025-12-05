class MealDetail {
  String id;
  String name;
  String thumb;
  String instructions;
  String? youtubeUrl;
  List<String> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.thumb,
    required this.instructions,
    this.youtubeUrl,
    required this.ingredients,
  });

  MealDetail.fromJson(Map<String, dynamic> data)
      : id = data['idMeal'],
        name = data['strMeal'],
        thumb = data['strMealThumb'],
        instructions = data['strInstructions'],
        youtubeUrl = data['strYoutube'],
        ingredients = [] {

    for (int i = 1; i <= 20; i++) {
      final ingredient = data['strIngredient$i'];
      final measure = data['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add('$measure $ingredient');
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'idMeal': id,
    'strMeal': name,
    'strMealThumb': thumb,
    'strInstructions': instructions,
    'strYoutube': youtubeUrl,
    'ingredients': ingredients,
  };
}