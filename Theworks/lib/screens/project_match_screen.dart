import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theworks/providers/project_providers.dart';

class ProjectMatchScreen extends ConsumerWidget {
  final List<String> selectedTags;

  const ProjectMatchScreen({super.key, required this.selectedTags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchedProjectsAsync = ref.watch(matchedProjectsProvider(selectedTags));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Projects'),
      ),
      body: matchedProjectsAsync.when(
        data: (projectsWithScores) {
          if (projectsWithScores.isEmpty) {
            return const Center(child: Text('No projects found.'));
          }
          return ListView.builder(
            itemCount: projectsWithScores.length,
            itemBuilder: (context, index) {
              final item = projectsWithScores[index];
              final project = item.$1;
              final score = item.$2;
              return Card(
                color: score > 0 ? Colors.green.shade50 : Colors.red.shade50,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Text(project.description),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Handle project selection
                  },
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}