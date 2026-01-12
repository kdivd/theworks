import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/classes/project.dart';

class ProjectService {
  final CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');

  Future<void> createProject(Project project) async {
    await _projectsCollection.add(project.toMap());
  }

  Future<List<Project>> getProjects() async {
    try {
      QuerySnapshot snapshot = await _projectsCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        return Project.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching projects: $e");
      return [];
    }
  }

  Future<List<Project>> getProjectsByTags(List<String> userTags) async {
    List<Project> allProjects = await getProjects();

    if (userTags.isEmpty) {
      return allProjects;
    }

    final lowerCaseUserTags = userTags.map((t) => t.toLowerCase()).toSet();
    final List<(Project, int)> scoredProjects = [];

    for (final project in allProjects) {
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
