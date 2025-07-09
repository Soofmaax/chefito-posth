import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recipe_semantic.dart';

class RecipeApiServiceSemantic {
  final String baseUrl;
  final http.Client client;

  RecipeApiServiceSemantic({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Future<List<Recipe>> fetchRecipes() async {
    final response = await client.get(Uri.parse('$baseUrl/recipes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Recipe> fetchRecipe(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/recipes/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Recipe.fromJson(data);
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  Future<AdaptedRecipeResponse> adaptRecipe(
      String id, String constraint) async {
    final response = await client.post(
      Uri.parse('$baseUrl/recipes/$id/adapt'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'constraint': constraint}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return AdaptedRecipeResponse.fromJson(data);
    } else {
      throw Exception('Failed to adapt recipe');
    }
  }
}

