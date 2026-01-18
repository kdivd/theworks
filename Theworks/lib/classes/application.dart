import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String applicationId;
  final String projectId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final Timestamp appliedAt;
  final String status;

  Application({
    required this.applicationId,
    required this.projectId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.appliedAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'appliedAt': appliedAt,
      'status': status,
    };
  }

  factory Application.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Application(
      applicationId: doc.id,
      projectId: data['projectId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      appliedAt: data['appliedAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
    );
  }
}
