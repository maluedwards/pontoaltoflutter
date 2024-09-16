class Project {
  final String projectName;
  final String recipeName;

  Project({required this.projectName, required this.recipeName});

  // Método para converter de Map para Project, tratando valores nulos
  factory Project.fromMap(Map<String, dynamic> data) {
    // Log dos dados recebidos
    print('Map recebido: $data');

    return Project(
      projectName: data['project_name'] != null ? data['project_name'] as String : '', // Tratamento de valor nulo
      recipeName: data['name'] != null ? data['name'] as String : '',   // Tratamento de valor nulo
    );
  }

  // Método para converter de Project para Map, se necessário
  Map<String, dynamic> toMap() {
    return {
      'project_name': projectName,
      'recipe_name': recipeName,
    };
  }
}
