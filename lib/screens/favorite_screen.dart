import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../widgets/meal_card.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Meal> favoriteMeals;
  final void Function(Meal meal) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteMeals,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (favoriteMeals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Favorites'),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No favorites added yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                'Add recipes from the list to see them here.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 200 / 244,
        ),
        itemCount: favoriteMeals.length,
        itemBuilder: (context, index) {
          final currentMeal = favoriteMeals[index];

          return MealCard(
            meal: currentMeal,
            isFavorite: true,
            onToggleFavorite: () => onToggleFavorite(currentMeal),
          );
        },
      ),
    );
  }
}