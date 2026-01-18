import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/classes/project.dart';
import 'package:theworks/classes/application.dart';

class ProjectService {
  final CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  final CollectionReference _applicationsCollection =
      FirebaseFirestore.instance.collection('applications');

  static final Map<String, List<String>> _tagImplications = {
    'full stack': ['front-end', 'back-end', 'web development'],
    'front-end': ['javascript', 'html', 'css', 'react', 'flutter'],
    'back-end': ['python', 'java', 'node', 'sql', 'database', 'c#'],
    'mobile': ['flutter', 'android', 'ios', 'react native'],
    'data science': ['python', 'machine learning', 'statistics', 'sql'],
  };

  Future<void> createProject(Project project) async {
    await _projectsCollection.add(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _projectsCollection.doc(projectId).delete();
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    await _projectsCollection.doc(projectId).update(data);
  }

  Future<void> applyForProject(Application application) async {
    await _applicationsCollection.add(application.toMap());
  }

  Stream<List<Application>> getApplicationsForProject(String projectId) {
    return _applicationsCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Application.fromFirestore(doc)).toList());
  }

  Future<bool> hasApplied(String projectId, String studentId) async {
    final query = await _applicationsCollection
        .where('projectId', isEqualTo: projectId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Stream<Set<String>> getAppliedProjectIdsStream(String studentId) {
    return _applicationsCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['projectId'] as String)
          .toSet();
    });
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
      debugPrint("Error fetching projects: $e");
      return [];
    }
  }

  Stream<List<Project>> getProjectsStream() {
    return _projectsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Project.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  List<(Project, int)> sortProjectsByTags(List<Project> projects, List<String> userTags) {
    if (userTags.isEmpty) {
      return projects.map((p) => (p, 0)).toList();
    }

    final expandedUserTags = _expandTags(userTags);
    final List<(Project, int)> matches = [];
    final List<Project> others = [];

    for (final project in projects) {
      int score = 0;

      for (final projectTag in project.tags) {
        if (expandedUserTags.contains(projectTag.toLowerCase())) {
          score++;
        }
      }

      if (score > 0) {
        matches.add((project, score));
      } else {
        others.add(project);
      }
    }

    matches.sort((a, b) => b.$2.compareTo(a.$2));

    return [...matches, ...others.map((p) => (p, 0))];
  }

  Set<String> _expandTags(List<String> tags) {
    Set<String> expandedTags = tags.map((t) => t.toLowerCase()).toSet();
    bool changed = true;

    while (changed) {
      changed = false;
      Set<String> newTags = {};
      for (var tag in expandedTags) {
        if (_tagImplications.containsKey(tag)) {
          for (var implied in _tagImplications[tag]!) {
            if (!expandedTags.contains(implied)) {
              newTags.add(implied);
              changed = true;
            }
          }
        }
      }
      expandedTags.addAll(newTags);
    }
    return expandedTags;
  }

  Future<List<(Project, int)>> getProjectsByTags(List<String> userTags) async {
    List<Project> allProjects = await getProjects();

    if (userTags.isEmpty) {
      return allProjects.map((p) => (p, 0)).toList();
    }

    final expandedUserTags = _expandTags(userTags);
    final List<(Project, int)> matches = [];
    final List<Project> others = [];

    for (final project in allProjects) {
      int score = 0;

      for (final projectTag in project.tags) {
        if (expandedUserTags.contains(projectTag.toLowerCase())) {
          score++;
        }
      }

      if (score > 0) {
        matches.add((project, score));
      } else {
        others.add(project);
      }
    }

    matches.sort((a, b) => b.$2.compareTo(a.$2));

    return [...matches, ...others.map((p) => (p, 0))];
  }
}
