class Meal {
  String id;
  String name;
  String thumb;

  Meal({
    required this.id,
    required this.name,
    required this.thumb,
  });

  Meal.fromJson(Map<String, dynamic> data)
      : id = data['idMeal'],
        name = data['strMeal'],
        thumb = data['strMealThumb'];

  Map<String, dynamic> toJson() => {
    'idMeal': id,
    'strMeal': name,
    'strMealThumb': thumb,
  };
}