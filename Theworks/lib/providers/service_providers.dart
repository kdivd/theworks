import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theworks/classes/project_service.dart';

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});
