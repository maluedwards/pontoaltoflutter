import 'package:flutter/material.dart';
import 'package:ponto_alto/model/reciperepository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ponto_alto/utils/difficulty_mapper.dart';
import 'package:ponto_alto/view/newproject.dart';

class RecipeDetails extends StatefulWidget {
  final String recipeName;

  const RecipeDetails({super.key, required this.recipeName});

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  late Future<Map<String, dynamic>?> recipeFuture;
  late Future<List<Map<String, dynamic>>> stitchRowsFuture;

  final RecipeRepository _recipeRepository = RecipeRepository();

  @override
  void initState() {
    super.initState();
    recipeFuture = _recipeRepository.getRecipeByName(widget.recipeName);
    stitchRowsFuture = _recipeRepository.getStitchRowsForRecipeByName(widget.recipeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.recipeDetailTitle}: ${widget.recipeName}'),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: FutureBuilder(
        future: Future.wait([recipeFuture, stitchRowsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${AppLocalizations.of(context)!.errorMessage}: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final recipe = snapshot.data![0] as Map<String, dynamic>?;
            final stitchRows = snapshot.data![1] as List<Map<String, dynamic>>;

            if (recipe == null) {
              return Center(child: Text(AppLocalizations.of(context)!.recipeNotFoundMessage));
            }

            // Adicionando um print para verificar os stitch rows
            print('Stitch rows: $stitchRows');

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.recipeField}: ${recipe['name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF84CE),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)!.difficultyField}: ${DifficultyMapper.getDifficultyText(recipe['difficulty'])}',
                    style: const TextStyle(fontSize: 18, color: Color(0xFFFF84CE)),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.stitchRowsLabel,
                    style: const TextStyle(fontSize: 20, color: Color(0xFF5941A9)),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: stitchRows.length,
                      itemBuilder: (context, index) {
                        final row = stitchRows[index];
                        return ListTile(
                          title: Text('${AppLocalizations.of(context)!.rowLabel} ${index + 1}: ${row['instructions']}'),
                          subtitle: Text('${row['stitches']} ${AppLocalizations.of(context)!.stitchesField}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Passando o nome da receita como argumento para a página de novo projeto
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NewProjectScreen(recipeName: recipe['name']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF84CE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocalizations.of(context)!.addNewProjectButton),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }
}
