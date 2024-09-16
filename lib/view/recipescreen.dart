import 'package:flutter/material.dart';
import 'package:ponto_alto/viewmodel/recipe_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ponto_alto/view/recipedetail.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar receitas no initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
      recipeViewModel.fetchAllRecipes();
    });
  }

  Future<void> _deleteRecipe(BuildContext context, String recipeName) async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    await recipeViewModel.deleteRecipe(recipeName);
    recipeViewModel.fetchAllRecipes(); // Recarrega as receitas após a exclusão
  }

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recipesTitle),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: recipeViewModel.isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : recipeViewModel.recipes.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context)!.noRecipesMessage,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF5941A9),
          ),
        ),
      )
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB685E8), Color(0xFFFFFFFF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recipesListTitle,
                    style: const TextStyle(
                      fontFamily: 'PoetsenOne',
                      fontSize: 24,
                      color: Color(0xFFFF84CE),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: recipeViewModel.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipeViewModel.recipes[index];
                        return ListTile(
                          title: Text(recipe['name']),
                          subtitle: Text(
                            '${AppLocalizations.of(context)!.difficultyField}: ${recipe['difficulty']}',
                          ),
                          onTap: () {
                            // Usando Navigator local (do RecipesScreen) para manter a BottomNavigationBar
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RecipeDetails(recipeName: recipe['name']),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteRecipe(context, recipe['name']);
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
