import 'package:flutter/material.dart';
import 'package:ponto_alto/model/reciperepository.dart';

class RecipesScreen extends StatelessWidget {
  final RecipeRepository _recipeRepository = RecipeRepository();

  RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ponto Alto'),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipeRepository.getAllRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes found.'));
          }

          final recipes = snapshot.data!;

          return Container(
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
                      const Text(
                        'Recipes List',
                        style: TextStyle(
                          fontFamily: 'PoetsenOne',
                          fontSize: 24,
                          color: Color(0xFFFF84CE),
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return ListTile(
                              title: Text(recipe['name']),
                              subtitle:
                                  Text('Difficulty: ${recipe['difficulty']}'),
                              onTap: () {
                                // Navigate to the recipe details screen or handle click
                              },
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
          );
        },
      ),
    );
  }
}

class DifficultyMapper {
  static const Map<int, String> difficultyMap = {
    1: 'Baixa',
    2: 'Média',
    3: 'Alta',
  };

  static String getDifficultyText(int difficulty) {
    return difficultyMap[difficulty] ?? 'Desconhecida';
  }
}
