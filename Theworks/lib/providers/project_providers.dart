import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theworks/classes/project.dart';
import 'package:theworks/providers/service_providers.dart';

final matchedProjectsProvider = FutureProvider.family<List<(Project, int)>, List<String>>((ref, tags) async {
  final projectService = ref.watch(projectServiceProvider);
  return projectService.getProjectsByTags(tags);
});
