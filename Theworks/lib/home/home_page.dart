import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class _HomeTabState extends State<HomeTab> {
  final ProjectService _projectService = ProjectService();

  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  List<String> _availableTags = ['All'];
  bool _isLoading = true;
  String _userRole = 'student';

  String _searchCity = '';
  String _filterLocationType = 'All';
  String _filterTag = 'All';

  bool get isQualified => _userRole == 'recruiter' || _userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _loadTags();
    _loadProjects();
  }

  Future<void> _loadTags() async {
    try {
      final String response = await rootBundle.loadString('assets/tags.json');
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _availableTags = ['All', ...data.cast<String>()];
        });
      }
    } catch (e) {
      debugPrint("Error loading tags: $e");
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final projects =
          await _projectService.getProjectsByTags(widget.selectedTags ?? []);
      if (mounted) {
        setState(() {
          _allProjects = projects;
          _runFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading projects: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _runFilters() {
    setState(() {
      _filteredProjects = _allProjects.where((p) {
        final cityMatch = _searchCity.isEmpty ||
            p.city.toLowerCase().contains(_searchCity.toLowerCase());

        final typeMatch = _filterLocationType == 'All' ||
            p.locationType == _filterLocationType;
        final tagMatch = _filterTag == 'All' || p.tags.contains(_filterTag);

        return cityMatch && typeMatch && tagMatch;
      }).toList();
    });
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() {
            _userRole = doc.data()?['role'] ?? 'student';
          });
        }
      } catch (e) {
        debugPrint("Error fetching role: $e");
      }
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempLocation = _filterLocationType;
        String tempTag = _filterTag;
        final TextEditingController cityController =
            TextEditingController(text: _searchCity);

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filter Projects",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Filter by City',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Filter by Skill / Tag",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: tempTag,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _availableTags.map((tag) {
                    return DropdownMenuItem(
                      value: tag,
                      child: Text(tag),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => tempTag = val);
                  },
                ),
                const SizedBox(height: 20),
                const Text("Location Type",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: ['All', 'On-site', 'Remote', 'Hybrid'].map((type) {
                    final isSelected = tempLocation == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => tempLocation = type);
                        }
                      },
                      selectedColor: AppColors.accentGold,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.darkBlue : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchCity = '';
                          _filterLocationType = 'All';
                          _filterTag = 'All';
                          _runFilters();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Reset"),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchCity = cityController.text.trim();
                          _filterLocationType = tempLocation;
                          _filterTag = tempTag;
                          _runFilters();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Projects'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: (_searchCity.isNotEmpty ||
                      _filterLocationType != 'All' ||
                      _filterTag != 'All')
                  ? AppColors.accentGold
                  : null,
            ),
            onPressed: _showFilterModal,
          ),
          if (isQualified)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.createProject);
                _loadProjects();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        _allProjects.isEmpty
                            ? "No projects found matching your tags."
                            : "No projects match your filters.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = _filteredProjects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(project.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.description,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Colors.grey),
                                Text(
                                  " ${project.city} • ${project.locationType}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
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
                ),
    );
  }
}
