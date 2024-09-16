import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_alto/model/projectrepository.dart';
import 'package:ponto_alto/model/reciperepository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

void main() {
  late ProjectRepository projectRepository;
  late RecipeRepository recipeRepository;
  late Database db;

  setUp(() async {
    // Inicializa o ambiente de teste FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Abre um banco de dados em memória
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Instancia os repositórios com o banco de dados em memória
    projectRepository = ProjectRepository();
    recipeRepository = RecipeRepository();

    // Insere uma receita para utilizar nos testes de projeto
    await recipeRepository.addRecipe('Test Recipe', 1);
  });

  tearDown(() async {
    // Fecha e deleta o banco de dados após o teste
    await db.close();
    await databaseFactory.deleteDatabase(inMemoryDatabasePath);
  });

  test('Insert project', () async {
    var project = {
      'project_name': 'Project Test',
      'recipe_id': 1,
      'done_stitches': 0,
      'current_stitch': 0,
      'current_row': 1
    };

    // Tenta inserir o projeto
    var result = await projectRepository.insertProject(project);
    expect(result, isNonZero);
  });

  test('Fetch project by name', () async {
    // Insere um projeto
    var project = {
      'project_name': 'Project Test',
      'recipe_id': 1,
      'done_stitches': 0,
      'current_stitch': 0,
      'current_row': 1
    };
    await projectRepository.insertProject(project);

    // Busca o projeto pelo nome
    var fetchedProject = await projectRepository.getProjectByName('Project Test');

    // Verifica se retornou algo
    expect(fetchedProject, isNotNull);
    expect(fetchedProject!['project_name'], 'Project Test');
  });

  test('Update project current stitch', () async {
    // Insere um projeto
    var project = {
      'project_name': 'Project Test',
      'recipe_id': 1,
      'done_stitches': 0,
      'current_stitch': 0,
      'current_row': 1
    };
    await projectRepository.insertProject(project);

    // Atualiza o número de pontos
    var result = await projectRepository.updateProjectStitch(10, 'Project Test');
    expect(result, isNonZero);

    // Verifica se o ponto foi atualizado
    var updatedProject = await projectRepository.getProjectByName('Project Test');
    expect(updatedProject!['current_stitch'], 10);
  });
}
