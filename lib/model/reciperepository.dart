import 'package:ponto_alto/model/database.dart';

class RecipeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Add a recipe
  Future<int> addRecipe(String name, int difficulty) async {
    Map<String, dynamic> recipe = {
      DatabaseHelper.columnRecipeName: name,
      DatabaseHelper.columnRecipeDifficulty: difficulty,
    };
    return await _databaseHelper.insertRecipe(recipe);
  }

  // Get all recipes
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    return await _databaseHelper.queryAllRecipes();
  }

  // Get recipe by name
  Future<Map<String, dynamic>?> getRecipeByName(String name) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> recipes = await db.query(
      DatabaseHelper.recipeTable,
      where: '${DatabaseHelper.columnRecipeName} = ?',
      whereArgs: [name],
    );
    if (recipes.isNotEmpty) {
      return recipes.first;
    }
    return null;
  }

  // Get recipe name by ID (nova função)
  Future<String?> getRecipeNameById(int recipeId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.recipeTable,
      where: '${DatabaseHelper.columnRecipeId} = ?',
      whereArgs: [recipeId],
    );
    if (result.isNotEmpty) {
      return result.first[DatabaseHelper.columnRecipeName] as String?;
    }
    return null;
  }

  // Get all stitch rows for a recipe by name
  Future<List<Map<String, dynamic>>> getStitchRowsForRecipeByName(String recipeName) async {
    final db = await _databaseHelper.database;
    final recipe = await getRecipeByName(recipeName);
    if (recipe != null) {
      final recipeId = recipe[DatabaseHelper.columnRecipeId];
      return await db.query(
        DatabaseHelper.stitchRowTable,
        where: '${DatabaseHelper.columnRowRecipeId} = ?',
        whereArgs: [recipeId],
      );
    }
    return [];
  }

  // Delete a recipe and its related stitch rows
  Future<int> deleteRecipe(int id) async {
    return await _databaseHelper.deleteRecipe(id);
  }

  // Add a stitch row for a recipe and update total stitches
  Future<int> addStitchRow(String instructions, int stitches, int recipeId) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnRowInstructions: instructions,
      DatabaseHelper.columnRowStitches: stitches,
      DatabaseHelper.columnRowRecipeId: recipeId,
    };
    return await _databaseHelper.insertStitchRow(row);
  }

  // Get all stitch rows for a recipe
  Future<List<Map<String, dynamic>>> getStitchRowsForRecipe(int recipeId) async {
    return await _databaseHelper.queryStitchRows(recipeId);
  }

  // Delete a stitch row and update total stitches
  Future<int> deleteStitchRow(int rowId, int recipeId) async {
    return await _databaseHelper.deleteStitchRow(rowId, recipeId);
  }
}
