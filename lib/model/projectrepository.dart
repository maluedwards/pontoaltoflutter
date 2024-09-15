import 'package:ponto_alto/model/database.dart';

class ProjectRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  //Add a new project
  Future<int> addProject({
    required int recipeId,
    required int doneStitches,
    required int currentStitch,
    required int currentRowId,
  }) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnProjectRecipeId: recipeId,
      DatabaseHelper.columnProjectDoneStitches: doneStitches,
      DatabaseHelper.columnProjectCurrentStitch: currentStitch,
      DatabaseHelper.columnProjectCurrentRowId: currentRowId,
    };
    return await _databaseHelper.insertProject(row);
  }

  //Get all projects
  Future<List<Map<String, dynamic>>> getAllProjects() async {
    return await _databaseHelper.queryAllProjects();
  }

  //Update project
  Future<int> updateProject({
    required int projectId,
    int? doneStitches,
    int? currentStitch,
    int? currentRowId,
  }) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnProjectId: projectId,
      if (doneStitches != null)
        DatabaseHelper.columnProjectDoneStitches: doneStitches,
      if (currentStitch != null)
        DatabaseHelper.columnProjectCurrentStitch: currentStitch,
      if (currentRowId != null)
        DatabaseHelper.columnProjectCurrentRowId: currentRowId,
    };
    return await _databaseHelper.updateProject(row);
  }

  // Delete a project
  Future<int> deleteProject(int projectId) async {
    return await _databaseHelper.deleteProject(projectId);
  }
}
