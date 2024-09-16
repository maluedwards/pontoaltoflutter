import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_alto/model/reciperepository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

void main() {
  late RecipeRepository recipeRepository;
  late Database db;

  setUp(() async {
    // Inicializa o ambiente de teste FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Abre um banco de dados em memória
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Instancia o RecipeRepository com o banco de dados em memória
    recipeRepository = RecipeRepository();
  });

  tearDown(() async {
    // Fecha e deleta o banco de dados após o teste
    await db.close();
    await databaseFactory.deleteDatabase(inMemoryDatabasePath);
  });

  test('Insert recipe', () async {
    var result = await recipeRepository.addRecipe('Test Recipe', 1);
    expect(result, isNonZero);
  });

  test('Fetch recipe by name', () async {
    // Adiciona uma receita
    await recipeRepository.addRecipe('Test Recipe', 1);

    // Busca a receita pelo nome
    var recipe = await recipeRepository.getRecipeByName('Test Recipe');
    expect(recipe, isNotNull);
    expect(recipe!['name'], 'Test Recipe');
  });

  test('Fetch stitch rows for recipe', () async {
    // Adiciona uma receita
    int recipeId = await recipeRepository.addRecipe('Test Recipe', 1);

    // Adiciona stitch rows para a receita
    await recipeRepository.addStitchRow('Instrução 1', 5, recipeId);
    await recipeRepository.addStitchRow('Instrução 2', 8, recipeId);

    // Busca as stitch rows para a receita
    var rows = await recipeRepository.getStitchRowsForRecipe(recipeId);
    expect(rows, isNotEmpty);
    expect(rows.length, 2);
  });
}
