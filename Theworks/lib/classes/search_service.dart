import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/classes/project.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final result = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: '${query}z')
        .get();

    // Also search by company name for recruiters
    final companyResult = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'recruiter')
        .where('companyName', isGreaterThanOrEqualTo: query)
        .where('companyName', isLessThan: '${query}z')
        .get();

    final Set<String> seenIds = {};
    final List<Map<String, dynamic>> users = [];

    for (var doc in [...result.docs, ...companyResult.docs]) {
      if (seenIds.contains(doc.id)) continue;
      seenIds.add(doc.id);
      
      final data = doc.data();
      data['uid'] = doc.id; // Ensure ID is included
      users.add(data);
    }

    return users;
  }

  Future<List<Project>> searchProjects(String query) async {
    if (query.isEmpty) return [];

    // Firestore doesn't support full-text search natively well. 
    // We'll do a basic startAt/endAt on 'name' field.
    final result = await _firestore
        .collection('projects')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    return result.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }
}
