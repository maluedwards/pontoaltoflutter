import 'package:flutter/material.dart';
import 'package:ponto_alto/model/projectrepository.dart';
import 'package:ponto_alto/model/project.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _projectRepository = ProjectRepository();

  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  // Função para buscar todos os projetos e atualizar a lista de projetos
  Future<void> fetchAllProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Buscando todos os projetos com o nome da receita
      List<Map<String, dynamic>> projectMaps = await _projectRepository.getAllProjects();

      // Log para verificar o conteúdo da lista de projetos com as receitas
      print('Projetos recuperados do banco: $projectMaps');

      // Mapeando os resultados para objetos Project
      _projects = projectMaps.map((projectMap) {
        print('Mapeando projeto: $projectMap');
        return Project.fromMap(projectMap);
      }).toList();

      // Log dos projetos após o mapeamento
      print('Projetos após mapeamento: $_projects');
    } catch (error) {
      // Caso ocorra algum erro durante a busca
      print('Erro ao buscar projetos: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Adiciona um novo projeto e atualiza a lista
  Future<void> addProject(Map<String, dynamic> projectData) async {
    await _projectRepository.insertProject(projectData);
    await fetchAllProjects();
  }

  // Exclui um projeto pelo nome
  Future<void> deleteProjectByName(String projectName) async {
    try {
      // Busca o projeto pelo nome
      Map<String, dynamic>? project = await _projectRepository.getProjectByName(projectName);

      if (project != null) {
        // Se o projeto existir, exclui pelo ID
        await _projectRepository.deleteProject(project['project_id']);
        await fetchAllProjects();
      } else {
        throw Exception("Projeto não encontrado");
      }
    } catch (error) {
      // Trata exceções no caso de erro
      print('Erro ao excluir projeto: $error');
    }
  }

  // Exclui todos os projetos
  Future<void> deleteAllProjects() async {
    try {
      List<Map<String, dynamic>> allProjects = await _projectRepository.getAllProjects();
      for (var project in allProjects) {
        await _projectRepository.deleteProject(project['project_id']);
      }
      fetchAllProjects();
    } catch (error) {
      print('Erro ao excluir todos os projetos: $error');
    }
  }
}
