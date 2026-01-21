import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:theworks/classes/post.dart';
import 'package:theworks/classes/post_service.dart';
import 'package:theworks/classes/project.dart';
import 'package:theworks/classes/project_service.dart';
import 'package:theworks/routes.dart';
import 'package:theworks/theme/app_colors.dart';

class HomeTab extends StatefulWidget {
  final List<String>? selectedTags;

  const HomeTab({super.key, this.selectedTags});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  final ProjectService _projectService = ProjectService();
  late TabController _tabController;

  List<String>? _fetchedTags;
  String? _userRole;
  String? _userCity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    if (widget.selectedTags != null) {
      _fetchedTags = widget.selectedTags;
      _fetchUserData();
    } else {
      _fetchUserData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            if (data.containsKey('role')) {
              _userRole = data['role'];
            }
            if (data.containsKey('city')) {
              _userCity = data['city'];
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Works'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Projects'),
            Tab(text: 'Feed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectsView(),
          _buildFeedView(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    final isRecruiter = _userRole == 'recruiter';
    final isProjectTab = _tabController.index == 0;

    if (isProjectTab) {
      if (isRecruiter) {
        return FloatingActionButton.extended(
          backgroundColor: AppColors.accentGold,
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.createProject,
              arguments: {'companyLocation': _userCity},
            );
          },
          label: const Text('Create Project',
              style: TextStyle(color: AppColors.darkBlue)),
          icon: const Icon(Icons.work, color: AppColors.darkBlue),
        );
      }
      return null; // Students can't create projects
    } else {
      // Feed Tab
      return FloatingActionButton.extended(
        backgroundColor: AppColors.accentGold,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createPost);
        },
        label: const Text('Create Post',
            style: TextStyle(color: AppColors.darkBlue)),
        icon: const Icon(Icons.post_add, color: AppColors.darkBlue),
      );
    }
  }

  Widget _buildProjectsView() {
    return StreamBuilder<List<Project>>(
      stream: _projectService.getProjectsStream(),
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
                if ((_fetchedTags == null || _fetchedTags!.isEmpty) &&
                    _userRole != 'recruiter')
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

        final allProjects = snapshot.data!;
        // Sort/Score projects
        var projectsWithScores =
            _projectService.sortProjectsByTags(allProjects, _fetchedTags ?? []);

        // Filter for Recruiters: Only show their own projects
        if (_userRole == 'recruiter') {
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          projectsWithScores = projectsWithScores
              .where((item) => item.$1.createdBy == currentUserId)
              .toList();

          if (projectsWithScores.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_history, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "You haven't posted any projects yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
        }

        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        return StreamBuilder<Set<String>>(
            stream: currentUserId != null
                ? _projectService.getAppliedProjectIdsStream(currentUserId)
                : Stream.value({}),
            builder: (context, appliedSnapshot) {
              final appliedProjectIds = appliedSnapshot.data ?? {};

              return ListView.builder(
                itemCount: projectsWithScores.length,
                itemBuilder: (context, index) {
                  final item = projectsWithScores[index];
                  final project = item.$1;
                  final score = item.$2;
                  final isApplied = appliedProjectIds.contains(project.id);

                  // Determine card color:
                  final cardColor = _userRole == 'recruiter'
                      ? Colors.white
                      : (score > 0 ? Colors.green.shade50 : Colors.red.shade50);

                  return Card(
                    color: cardColor,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(project.name)),
                          if (isApplied)
                            const Chip(
                              label: Text('Applied',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white)),
                              backgroundColor: Colors.green,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (project.companyName != null &&
                                    project.companyName!.isNotEmpty)
                                ? '${project.companyName} • ${project.city}'
                                : project.city,
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
            });
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
