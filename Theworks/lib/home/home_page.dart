import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:theworks/classes/post.dart';
import 'package:theworks/classes/post_service.dart';
import 'package:theworks/classes/project.dart';
import 'package:theworks/classes/project_service.dart';
import 'package:theworks/routes.dart';

class HomeTab extends StatefulWidget {
  final List<String>? selectedTags;

  const HomeTab({super.key, this.selectedTags});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PostService _postService = PostService();
  final ProjectService _projectService = ProjectService();

  List<String>? _fetchedTags;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.selectedTags != null) {
      _fetchedTags = widget.selectedTags;
      _isLoading = false;
    } else {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            if (data.containsKey('tags')) {
              _fetchedTags = List<String>.from(data['tags']);
            }
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('The Works'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Projects'),
              Tab(text: 'Feed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProjectsView(),
            _buildFeedView(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createPost);
          },
          label: const Text('Create Post'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProjectsView() {
    return FutureBuilder<List<Project>>(
      // If fetchedTags is null here, getProjectsByTags handles empty list gracefully
      future: _projectService.getProjectsByTags(_fetchedTags ?? []),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work_off, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                const Text(
                  "No projects found.",
                  style: TextStyle(color: Colors.grey),
                ),
                if (_fetchedTags == null || _fetchedTags!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.tags);
                      },
                      child: const Text("Select Tags"),
                    ),
                  )
              ],
            ),
          );
        }

        final projects = snapshot.data!;
        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(project.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.city,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.projectDetail,
                    arguments: project,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedView() {
    return StreamBuilder<List<Post>>(
      stream: _postService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "No posts yet. Be the first to post!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(post.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'By ${post.authorName}',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.postDetail,
                    arguments: post,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
