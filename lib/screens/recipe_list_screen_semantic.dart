import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_semantic.dart';
import '../services/recipe_api_service_semantic.dart';

class RecipeListNotifier extends ChangeNotifier {
  final RecipeApiServiceSemantic api;
  List<Recipe> recipes = [];
  bool loading = false;
  String? error;

  RecipeListNotifier({required this.api});

  Future<void> loadRecipes() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      recipes = await api.fetchRecipes();
    } catch (_) {
      error = 'Failed to load recipes';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class RecipeListScreenSemantic extends StatefulWidget {
  final RecipeApiServiceSemantic apiService;
  const RecipeListScreenSemantic({Key? key, required this.apiService}) : super(key: key);

  @override
  State<RecipeListScreenSemantic> createState() => _RecipeListScreenSemanticState();
}

class _RecipeListScreenSemanticState extends State<RecipeListScreenSemantic> {
  late final RecipeListNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = RecipeListNotifier(api: widget.apiService);
    notifier.loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeListNotifier>.value(
      value: notifier,
      child: Consumer<RecipeListNotifier>(
        builder: (context, state, _) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          return ListView.builder(
            itemCount: state.recipes.length,
            itemBuilder: (context, index) {
              final recipe = state.recipes[index];
              return Card(
                child: ListTile(
                  title: Text(recipe.title),
                  subtitle: Text(recipe.description),
                  onTap: () {
                    Navigator.of(context).pushNamed('/recipe/${recipe.recipeId}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

