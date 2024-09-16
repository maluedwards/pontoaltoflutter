import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ponto_alto/model/projectrepository.dart';
import 'package:provider/provider.dart';
import 'package:ponto_alto/viewmodel/project_viewmodel.dart';
import 'package:ponto_alto/model/reciperepository.dart'; // Para obter o ID da receita

class NewProjectScreen extends StatefulWidget {
  final String recipeName;

  const NewProjectScreen({super.key, required this.recipeName});

  @override
  _NewProjectScreenState createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final ProjectRepository _projectRepository = ProjectRepository();
  final RecipeRepository _recipeRepository = RecipeRepository(); // Para buscar o ID da receita
  String projectName = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newProjectTitle),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB685E8), Color(0xFFFFFFFF)],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.projectNameField,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  projectName = value;
                });
                // Log para verificar a mudança no nome do projeto
                print('Nome do projeto: $projectName');
              },
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.recipeField}:',
                  style: const TextStyle(fontSize: 22, color: Color(0xFF5941A9)),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.recipeName,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const Spacer(),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                if (projectName.isEmpty) {
                  setState(() {
                    error = AppLocalizations.of(context)!.projectNameField + ' is required';
                  });
                  return;
                }

                try {
                  // Log para verificar a busca da receita
                  print('Buscando receita: ${widget.recipeName}');
                  final recipe = await _recipeRepository.getRecipeByName(widget.recipeName);

                  if (recipe == null) {
                    setState(() {
                      error = 'Recipe not found';
                    });
                    print('Receita não encontrada!');
                    return;
                  }

                  final recipeId = recipe['id']; // Aqui pegamos o ID da receita
                  print('ID da receita encontrada: $recipeId');

                  // Log para os dados do projeto
                  print('Inserindo projeto: $projectName com receita $recipeId');

                  await _projectRepository.insertProject({
                    'project_name': projectName,
                    'recipe_id': recipeId, // Agora passando o ID da receita
                    'done_stitches': 0,
                    'current_stitch': 0,
                    'current_row': 1,
                  });

                  // Log após a inserção do projeto
                  print('Projeto inserido com sucesso!');

                  // Atualizando a lista de projetos
                  Provider.of<ProjectViewModel>(context, listen: false).fetchAllProjects();

                  // Redirecionando para a HomeScreen
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                } catch (e) {
                  setState(() {
                    error = 'Failed to save project: $e';
                  });
                  print('Erro ao salvar o projeto: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF84CE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(AppLocalizations.of(context)!.saveProjectButton),
            ),
          ],
        ),
      ),
    );
  }
}
