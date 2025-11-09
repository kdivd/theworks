import 'package:flutter/material.dart';
import 'package:theworks/classes/project.dart';
import 'package:theworks/classes/project_service.dart';

class ProjectMatchScreen extends StatefulWidget {
  final List<String> selectedTags;

  const ProjectMatchScreen({super.key, required this.selectedTags});

  @override
  State<ProjectMatchScreen> createState() => _ProjectMatchScreenState();
}

class _ProjectMatchScreenState extends State<ProjectMatchScreen> {
  late Future<List<Project>> _matchedProjects;
  final ProjectService _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _matchedProjects = _projectService.getProjectsByTags(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Projects'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _matchedProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects found.'));
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
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
          }
        },
      ),
    );
  }
}
