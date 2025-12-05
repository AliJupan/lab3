import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';
import '../models/meal_detail.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final ApiService _api = ApiService();
  MealDetail? _meal;
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is MealDetail) {
        setState(() {
          _meal = args;
          _isLoading = false;
        });
      }
      else if (args is Meal) {
        _fetchFullDetails(args.id);
      }

      _isInit = false;
    }
  }

  void _fetchFullDetails(String id) async {
    final data = await _api.getMealDetails(id);
    if (mounted) {
      setState(() {
        _meal = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchYoutube() async {
    if (_meal?.youtubeUrl != null) {
      final uri = Uri.parse(_meal!.youtubeUrl!);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint("Could not launch $_meal!.youtubeUrl");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_meal == null) {
      return const Scaffold(body: Center(child: Text("Error loading recipe")));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_meal!.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              _meal!.thumb,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      "Ingredients",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)
                  ),
                  const Divider(),

                  ..._meal!.ingredients.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text("• $i", style: const TextStyle(fontSize: 16)),
                  )),

                  const SizedBox(height: 24),

                  const Text(
                      "Instructions",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)
                  ),
                  const Divider(),

                  Text(
                    _meal!.instructions,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  if (_meal!.youtubeUrl != null && _meal!.youtubeUrl!.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _launchYoutube,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Watch on YouTube"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}