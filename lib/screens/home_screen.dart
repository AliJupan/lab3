import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../widgets/category_grid.dart';
import '../models/meal_model.dart';
import '../screens/favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  final Set<Meal> favoriteMeals;
  final void Function(Meal meal) onToggleFavorite;

  const HomeScreen({
    super.key,
    required this.favoriteMeals,
    required this.onToggleFavorite,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _api.getCategories();
    setState(() {
      _allCategories = data;
      _filteredCategories = data;
      _isLoading = false;
    });
  }

  void _filter(String query) {
    setState(() {
      _filteredCategories = _allCategories
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  void _onRandomPressed() async {
    final randomMeal = await _api.getRandomMeal();
    if (randomMeal != null && mounted) {
      Navigator.pushNamed(context, '/details', arguments: randomMeal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Categories"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorite Recipes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => FavoritesScreen(
                    favoriteMeals: widget.favoriteMeals.toList(),
                    onToggleFavorite: widget.onToggleFavorite,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random Recipe',
            onPressed: _onRandomPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CategoryGrid(categories: _filteredCategories),
          ),
        ],
      ),
    );
  }
}