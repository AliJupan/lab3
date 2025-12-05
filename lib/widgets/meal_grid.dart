import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import 'meal_card.dart';

class MealGrid extends StatelessWidget {
  final List<Meal> meals;
  final Set<Meal> favoriteMeals;
  final void Function(Meal meal) onToggleFavorite;

  const MealGrid({
    super.key,
    required this.meals,
    required this.favoriteMeals,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 200 / 244,
      ),
      itemCount: meals.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final currentMeal = meals[index];

        return MealCard(
          meal: currentMeal,
          isFavorite: favoriteMeals.contains(currentMeal),
          onToggleFavorite: () => onToggleFavorite(currentMeal),
        );
      },
    );
  }
}