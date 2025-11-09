import 'package:theworks/classes/project.dart';

class ProjectService {
  final List<Project> _projects = [
    Project(
      name: 'Flutter Frontend Project',
      description:
          'A project to build a new frontend for a mobile app using Flutter.',
      tags: ['Frontend', 'Flutter', 'Mobile'],
    ),
    Project(
      name: 'Backend API with Node.js',
      description: 'Develop a RESTful API for our new e-commerce platform.',
      tags: ['Backend', 'API', 'Node.js', 'E-commerce'],
    ),
    Project(
      name: 'Data Science for Marketing',
      description: 'Analyze marketing data to identify customer trends.',
      tags: ['Data Science', 'Marketing', 'Analytics'],
    ),
    Project(
      name: 'UI/UX Redesign for Website',
      description:
          'Redesign the user interface and user experience of our main website.',
      tags: ['UI/UX', 'Design', 'Web'],
    ),
    Project(
      name: 'Mobile Game with Unity',
      description: 'Create a new mobile game using the Unity engine.',
      tags: ['Game Development', 'Unity', 'Mobile', 'Unity Game Development'],
    ),
  ];

  Future<List<Project>> getProjects() async {
    await Future.delayed(const Duration(seconds: 1));
    return _projects;
  }

  Future<List<Project>> getProjectsByTags(List<String> tags) async {
    await Future.delayed(const Duration(seconds: 1));

    if (tags.isEmpty) {
      return _projects;
    }

    final lowerCaseUserTags = tags.map((t) => t.toLowerCase()).toSet();

    final List<(Project, int)> scoredProjects = [];

    for (final project in _projects) {
      int score = 0;
      for (final projectTag in project.tags) {
        if (lowerCaseUserTags.contains(projectTag.toLowerCase())) {
          score++;
        }
      }
      if (score > 0) {
        scoredProjects.add((project, score));
      }
    }

    scoredProjects.sort((a, b) => b.$2.compareTo(a.$2));

    return scoredProjects.map((record) => record.$1).toList();
  }
}
