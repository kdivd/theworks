import 'package:flutter/material.dart';
import 'package:theworks/classes/search_service.dart';
import 'package:theworks/classes/project.dart';
import 'package:theworks/routes.dart';
import 'package:theworks/theme/app_colors.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  late TabController _tabController;

  List<Map<String, dynamic>> _users = [];
  List<Project> _projects = [];
  bool _isSearching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _query = query;
      _isSearching = true;
    });

    if (query.isEmpty) {
      setState(() {
        _users = [];
        _projects = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final users = await _searchService.searchUsers(query);
      final projects = await _searchService.searchProjects(query);

      if (mounted) {
        setState(() {
          _users = users;
          _projects = projects;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search users, companies, projects...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
          onChanged: _performSearch,
        ),
        backgroundColor: AppColors.darkBlue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          tabs: const [
            Tab(text: 'People & Companies'),
            Tab(text: 'Projects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(),
          _buildProjectList(),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty) {
      return Center(
        child: Text(_query.isEmpty ? 'Start searching...' : 'No users found.'),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final role = user['role'] ?? 'student';
        final isRecruiter = role == 'recruiter';
        final name = isRecruiter
            ? (user['companyName'] ?? user['displayName'] ?? 'Unknown')
            : (user['displayName'] ?? 'Unknown');
        final subtitle = isRecruiter ? 'Company' : 'Student';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.darkBlue,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
          ),
          title: Text(name),
          subtitle: Text(subtitle),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.userProfile,
              arguments: user,
            );
          },
        );
      },
    );
  }

  Widget _buildProjectList() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_projects.isEmpty) {
      return Center(
        child: Text(_query.isEmpty ? 'Start searching...' : 'No projects found.'),
      );
    }

    return ListView.builder(
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        return ListTile(
          leading: const Icon(Icons.work, color: AppColors.darkBlue),
          title: Text(project.name),
          subtitle: Text(project.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.projectDetail,
              arguments: project,
            );
          },
        );
      },
    );
  }
}
