import 'package:flutter/material.dart';
import 'package:ponto_alto/viewmodel/project_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Função para buscar uma frase aleatória
Future<String> fetchRandomCrochetQuote() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/crochetQuotes/random'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    return data['quote'];
  } else {
    throw Exception('Failed to load quote');
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectViewModel = Provider.of<ProjectViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeTitle),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: projectViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<String>(
        future: fetchRandomCrochetQuote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            String quote = snapshot.data!;

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
                child: Column(
                  children: [
                    // Container menor para a frase aleatória
                    Container(
                      height: 100, // Menor altura para o container da frase
                      child: Card(
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              quote,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Card(
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.projectsListTitle,
                                style: const TextStyle(
                                  fontFamily: 'PoetsenOne',
                                  fontSize: 24,
                                  color: Color(0xFFFF84CE),
                                ),
                              ),
                              const Divider(),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: projectViewModel.projects.length,
                                  itemBuilder: (context, index) {
                                    final project = projectViewModel.projects[index];
                                    return ListTile(
                                      title: Text(project.projectName),
                                      subtitle: Text(
                                        '${AppLocalizations.of(context)!.recipeField}: ${project.recipeName}',
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/project-detail',
                                          arguments: project.projectName,
                                        );
                                      },
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          projectViewModel.deleteProjectByName(project.projectName);
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
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }
}
