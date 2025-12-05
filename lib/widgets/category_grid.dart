import 'package:flutter/material.dart';
import '../models/category_model.dart';
import 'category_card.dart';

class CategoryGrid extends StatefulWidget {
  final List<Category> categories;

  const CategoryGrid({super.key, required this.categories});

  @override
  State<StatefulWidget> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 250,
      ),
      itemCount: widget.categories.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return CategoryCard(category: widget.categories[index]);
      },
    );
  }
}