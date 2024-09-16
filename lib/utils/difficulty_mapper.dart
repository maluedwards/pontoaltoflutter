class DifficultyMapper {
  static const Map<int, String> difficultyMap = {
    1: 'Basic',
    2: 'Intermediate',
    3: 'Advanced',
  };

  static String getDifficultyText(int difficulty) {
    return difficultyMap[difficulty] ?? 'Unknown';
  }
}
