import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/recipe_semantic.dart';
import '../models/recognition_result.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class RecipeApiServiceSemantic {
  final String baseUrl;
  final http.Client client;

  RecipeApiServiceSemantic({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Future<List<Recipe>> fetchRecipes() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/recipes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode >= 500) {
        throw ApiException('Server error (${response.statusCode})');
      } else {
        throw ApiException('Request failed (${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<Recipe> fetchRecipe(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/recipes/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Recipe.fromJson(data);
      } else if (response.statusCode == 404) {
        throw ApiException('Recipe not found');
      } else if (response.statusCode >= 500) {
        throw ApiException('Server error (${response.statusCode})');
      } else {
        throw ApiException('Request failed (${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<AdaptedRecipeResponse> adaptRecipe(
      String id, String constraint) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/recipes/$id/adapt'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'constraint': constraint}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return AdaptedRecipeResponse.fromJson(data);
      } else if (response.statusCode == 400) {
        throw ApiException('Constraint not supported');
      } else if (response.statusCode >= 500) {
        throw ApiException('Server error (${response.statusCode})');
      } else {
        throw ApiException('Request failed (${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<RecognitionResponse> recognizeIngredients(File imageFile) async {
    final uri = Uri.parse('$baseUrl/ingredients/recognize');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    http.StreamedResponse streamed;
    try {
      streamed = await request.send();
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return RecognitionResponse.fromJson(data);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error (${response.statusCode})');
    } else {
      throw ApiException('Request failed (${response.statusCode})');
    }
  }
}

