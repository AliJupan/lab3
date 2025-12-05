import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../models/meal_model.dart';
import '../widgets/meal_grid.dart';
import 'favorite_screen.dart';

class MealsScreen extends StatefulWidget {
  final Set<Meal> favoriteMeals;
  final void Function(Meal meal) onToggleFavorite;

  const MealsScreen({
    super.key,
    required this.favoriteMeals,
    required this.onToggleFavorite,
  });

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final ApiService _api = ApiService();

  List<Meal> _meals = [];
  bool _isLoading = true;
  Category? _categoryArgs;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Category) {
        _categoryArgs = args;
        _loadMeals(_categoryArgs!.name);
      }
      _isInit = false;
    }
  }

  void _loadMeals(String categoryName) async {
    setState(() => _isLoading = true);
    final data = await _api.getMealsByCategory(categoryName);
    setState(() {
      _meals = data;
      _isLoading = false;
    });
  }

  void _searchGlobal(String query) async {
    if (query.isEmpty && _categoryArgs != null) {
      _loadMeals(_categoryArgs!.name);
      return;
    }
    setState(() => _isLoading = true);
    final data = await _api.searchGlobal(query);
    setState(() {
      _meals = data;
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final title = _categoryArgs?.name ?? 'Meals';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
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
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search dishes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: _searchGlobal,
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _meals.isEmpty
                ? const Center(child: Text("No meals found."))
                : MealGrid(
              meals: _meals,
              favoriteMeals: widget.favoriteMeals,
              onToggleFavorite: widget.onToggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}