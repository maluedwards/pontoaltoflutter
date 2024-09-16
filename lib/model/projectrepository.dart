import 'package:ponto_alto/model/database.dart';

class ProjectRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Add a new project
  Future<int> insertProject(Map<String, dynamic> project) async {
    return await _databaseHelper.insertProject(project);
  }

  // Get all projects with associated recipe names
  Future<List<Map<String, dynamic>>> getAllProjects() async {
    // Agora utiliza a query que faz JOIN com a tabela de receitas
    return await _databaseHelper.queryAllProjectsWithRecipe();
  }

  // Get project by name
  Future<Map<String, dynamic>?> getProjectByName(String projectName) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> projects = await db.query(
      DatabaseHelper.projectTable,
      where: '${DatabaseHelper.columnProjectName} = ?',
      whereArgs: [projectName],
    );
    if (projects.isNotEmpty) {
      return projects.first;
    }
    return null;
  }

  // Update the current stitch count for a project
  Future<int> updateProjectStitch(int newCount, String projectName) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.projectTable,
      {DatabaseHelper.columnProjectCurrentStitch: newCount},
      where: '${DatabaseHelper.columnProjectName} = ?',
      whereArgs: [projectName],
    );
  }

  // Delete a project by ID
  Future<int> deleteProject(int projectId) async {
    return await _databaseHelper.deleteProject(projectId);
  }
}
