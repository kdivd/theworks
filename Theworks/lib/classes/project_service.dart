// import 'package:theworks/classes/project.dart';
//
// class ProjectService {
//   final List<Project> _projects = [
//     Project(
//       name: 'Flutter Frontend Project',
//       description:
//           'A project to build a new frontend for a mobile app using Flutter.',
//       tags: ['Frontend', 'Flutter', 'Mobile'],
//     ),
//     Project(
//       name: 'Backend API with Node.js',
//       description: 'Develop a RESTful API for our new e-commerce platform.',
//       tags: ['Backend', 'API', 'Node.js', 'E-commerce'],
//     ),
//     Project(
//       name: 'Data Science for Marketing',
//       description: 'Analyze marketing data to identify customer trends.',
//       tags: ['Data Science', 'Marketing', 'Analytics'],
//     ),
//     Project(
//       name: 'UI/UX Redesign for Website',
//       description:
//           'Redesign the user interface and user experience of our main website.',
//       tags: ['UI/UX', 'Design', 'Web'],
//     ),
//     Project(
//       name: 'Mobile Game with Unity',
//       description: 'Create a new mobile game using the Unity engine.',
//       tags: ['Game Development', 'Unity', 'Mobile', 'Unity Game Development'],
//     ),
//   ];
//
//   Future<List<Project>> getProjects() async {
//     await Future.delayed(const Duration(seconds: 1));
//     return _projects;
//   }
//
//   Future<List<Project>> getProjectsByTags(List<String> tags) async {
//     await Future.delayed(const Duration(seconds: 1));
//
//     if (tags.isEmpty) {
//       // If no tags are selected, return all projects or an empty list (your choice)
//       return _projects;
//     }
//
//     // 1. Normalize user's selected tags to lowercase for case-insensitive matching
//     final lowerCaseUserTags = tags.map((t) => t.toLowerCase()).toSet();
//
//     // A list to hold our project objects along with their calculated match score
//     final List<(Project project, int score)> scoredProjects = [];
//
//     for (final project in _projects) {
//       int score = 0;
//
//       // 2. Calculate the score by counting matching tags
//       for (final projectTag in project.tags) {
//         // Normalize project tag case for comparison
//         if (lowerCaseUserTags.contains(projectTag.toLowerCase())) {
//           score++;
//         }
//       }
//
//       // 3. Filter: Only add projects that have at least one match
//       if (score > 0) {
//         // --- FIX HERE: Use Positional Record Construction ---
//         scoredProjects.add((project, score));
//       }
//     }
//
//     // 4. Sort the list: Rank by score (highest score first)
//     // Access the score using the positional accessor .$2
//     scoredProjects.sort((a, b) => b.$2.compareTo(a.$2));
//
//     // 5. Return just the Project objects from the sorted list
//     // Access the Project using the positional accessor .$1
//     return scoredProjects.map((record) => record.$1).toList();
//   }
// }
// lib/classes/project_service.dart
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
