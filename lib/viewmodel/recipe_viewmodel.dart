import 'package:flutter/material.dart';
import 'package:ponto_alto/model/reciperepository.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository = RecipeRepository();

  bool _isLoading = false;
  List<Map<String, dynamic>> _recipes = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get recipes => _recipes;

  Future<void> fetchAllRecipes() async {
    _setLoading(true);
    _recipes = await _recipeRepository.getAllRecipes();
    _setLoading(false);
  }

  Future<void> addRecipe(String name, int difficulty, List<Map<String, dynamic>> stitchRows) async {
    _setLoading(true);
    final recipeId = await _recipeRepository.addRecipe(name, difficulty);
    for (var row in stitchRows) {
      await _recipeRepository.addStitchRow(row['instructions'], row['stitches'], recipeId);
    }
    await fetchAllRecipes();
    _setLoading(false);
  }

  Future<void> deleteRecipe(String name) async {
    _setLoading(true);
    final recipe = await _recipeRepository.getRecipeByName(name);
    if (recipe != null) {
      await _recipeRepository.deleteRecipe(recipe['id']);
    }
    await fetchAllRecipes();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
