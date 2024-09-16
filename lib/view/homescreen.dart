import 'package:flutter/material.dart';
import 'package:ponto_alto/viewmodel/project_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final projectViewModel = Provider.of<ProjectViewModel>(context);

    // Log para verificar se os projetos estão sendo carregados
    print('Carregando lista de projetos...');
    print('Total de projetos: ${projectViewModel.projects.length}');
    print('Projetos: ${projectViewModel.projects}');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeTitle),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: projectViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : projectViewModel.projects.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context)!.noProjectsMessage,
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

                        // Log do projeto atual
                        print('Projeto ${index + 1}: ${project.projectName}');
                        print('Nome da Receita: ${project.recipeName}');

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
      ),
    );
  }

}
