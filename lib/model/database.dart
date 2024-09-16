import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "pontoalto_database.db";
  static const _databaseVersion = 4;

  static const recipeTable = 'recipe';
  static const stitchRowTable = 'stitch_row';
  static const projectTable = 'project';

  // Recipe table columns
  static const columnRecipeId = 'id';
  static const columnRecipeName = 'name';
  static const columnRecipeDifficulty = 'difficulty';
  static const columnRecipeTotalStitches = 'total_stitches';

  // Stitch row table columns
  static const columnRowId = 'row_id';
  static const columnRowInstructions = 'instructions';
  static const columnRowStitches = 'stitches';
  static const columnRowRecipeId = 'recipe_id'; // Foreign key linking to recipe table

  // Project table columns
  static const columnProjectId = 'project_id';
  static const columnProjectName = 'project_name';
  static const columnProjectDoneStitches = 'done_stitches';
  static const columnProjectCurrentStitch = 'current_stitch';
  static const columnProjectCurrentRowId = 'current_row';
  static const columnProjectRecipeId = 'recipe_id';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Table creation
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $recipeTable (
        $columnRecipeId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnRecipeName TEXT NOT NULL,
        $columnRecipeDifficulty INTEGER NOT NULL,
        $columnRecipeTotalStitches INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $stitchRowTable (
        $columnRowId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnRowInstructions TEXT NOT NULL,
        $columnRowStitches INTEGER NOT NULL,
        $columnRowRecipeId INTEGER NOT NULL,
        FOREIGN KEY ($columnRowRecipeId) REFERENCES $recipeTable ($columnRecipeId)
      )
    ''');

    await db.execute('''
      CREATE TABLE $projectTable (
        $columnProjectId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnProjectName TEXT NOT NULL,
        $columnProjectDoneStitches INTEGER NOT NULL DEFAULT 0,
        $columnProjectCurrentStitch INTEGER NOT NULL DEFAULT 0,
        $columnProjectCurrentRowId INTEGER NOT NULL,
        $columnProjectRecipeId INTEGER NOT NULL,
        FOREIGN KEY ($columnProjectCurrentRowId) REFERENCES $stitchRowTable ($columnRowId),
        FOREIGN KEY ($columnProjectRecipeId) REFERENCES $recipeTable ($columnRecipeId)
      )
    ''');
  }

  // Handle migration for new database versions
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE $projectTable ADD COLUMN $columnProjectName TEXT;
      ''');
    }
  }

  // New recipe
  Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    Database db = await instance.database;
    return await db.insert(recipeTable, recipe);
  }

  // New row
  Future<int> insertStitchRow(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int result = await db.insert(stitchRowTable, row);

    // Update total stitches for the recipe
    int recipeId = row[columnRowRecipeId];
    await _updateTotalStitches(db, recipeId);

    return result;
  }

  // Updating total stitches after stitch row insertion, update, or deletion
  Future<void> _updateTotalStitches(Database db, int recipeId) async {
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM($columnRowStitches) as total_stitches
      FROM $stitchRowTable
      WHERE $columnRowRecipeId = ?
    ''', [recipeId]);

    int totalStitches = result.first['total_stitches'] ?? 0;

    await db.update(
      recipeTable,
      {columnRecipeTotalStitches: totalStitches},
      where: '$columnRecipeId = ?',
      whereArgs: [recipeId],
    );
  }

  // Query all recipes
  Future<List<Map<String, dynamic>>> queryAllRecipes() async {
    Database db = await instance.database;
    return await db.query(recipeTable);
  }

  // Query all stitch rows for a specific recipe
  Future<List<Map<String, dynamic>>> queryStitchRows(int recipeId) async {
    Database db = await instance.database;
    return await db.query(
      stitchRowTable,
      where: '$columnRowRecipeId = ?',
      whereArgs: [recipeId],
    );
  }

  // Delete a stitch row
  Future<int> deleteStitchRow(int rowId, int recipeId) async {
    Database db = await instance.database;
    int result = await db
        .delete(stitchRowTable, where: '$columnRowId = ?', whereArgs: [rowId]);

    await _updateTotalStitches(db, recipeId);

    return result;
  }

  // Delete recipe
  Future<int> deleteRecipe(int recipeId) async {
    Database db = await instance.database;
    return await db.delete(recipeTable,
        where: '$columnRecipeId = ?', whereArgs: [recipeId]);
  }

  // Insert new project
  Future<int> insertProject(Map<String, dynamic> project) async {
    Database db = await instance.database;
    return await db.insert(projectTable, project);
  }

  // Query all projects with recipe name using a JOIN
  Future<List<Map<String, dynamic>>> queryAllProjectsWithRecipe() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT p.$columnProjectId, p.$columnProjectName, p.$columnProjectDoneStitches, 
             p.$columnProjectCurrentStitch, p.$columnProjectCurrentRowId, 
             p.$columnProjectRecipeId, r.$columnRecipeName
      FROM $projectTable p
      JOIN $recipeTable r ON p.$columnProjectRecipeId = r.$columnRecipeId
    ''');
  }

  // Update project
  Future<int> updateProject(Map<String, dynamic> project) async {
    Database db = await instance.database;
    int projectId = project[columnProjectId];
    return await db.update(
      projectTable,
      project,
      where: '$columnProjectId = ?',
      whereArgs: [projectId],
    );
  }

  // Delete a project
  Future<int> deleteProject(int projectId) async {
    Database db = await instance.database;
    return await db.delete(
      projectTable,
      where: '$columnProjectId = ?',
      whereArgs: [projectId],
    );
  }
}
