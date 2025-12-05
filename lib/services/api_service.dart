import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lab3/models/meal_detail.dart';
import 'package:lab3/models/meal_model.dart';

import '../models/category_model.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    List<Category> categoryList = [];

    final response = await http.get(
      Uri.parse('$_baseUrl/categories.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['categories'] != null) {
        for (var item in data['categories']) {
          categoryList.add(Category.fromJson(item));
        }
      }
    }

    return categoryList;
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    List<Meal> mealList = [];

    final response = await http.get(
      Uri.parse('$_baseUrl/filter.php?c=$category'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['meals'] != null) {
        for (var item in data['meals']) {
          mealList.add(Meal.fromJson(item));
        }
      }
    }

    return mealList;
  }

  Future<List<Meal>> searchGlobal(String query) async {
    List<Meal> mealList = [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['meals'] != null) {
          for (var item in data['meals']) {
            mealList.add(Meal.fromJson(item));
          }
        }
      }
      return mealList;
    } catch (e) {
      return [];
    }
  }

  Future<MealDetail?> getMealDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return MealDetail.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<MealDetail?> getRandomMeal() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/random.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return MealDetail.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}