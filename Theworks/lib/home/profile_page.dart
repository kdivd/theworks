import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:choice/choice.dart';
import 'package:theworks/routes.dart';
import 'package:theworks/theme/app_colors.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final User? _user = FirebaseAuth.instance.currentUser;

  // 1. Predefined Schools to enforce exact naming
  final List<String> _schools = [
    'Grafisch Lyceum Utrecht',
    'Hogeschool Utrecht',
    'Hogeschool van Amsterdam',
    'Techniek College Rotterdam',
    'Media College Amsterdam',
    'Avans Hogeschool',
    'Fontys Hogeschool',
    'Other'
  ];

  // --- SCHOOL EDITING ---
  Future<void> _showEditSchoolDialog(String? currentSchool) async {
    String? selectedSchool =
        _schools.contains(currentSchool) ? currentSchool : null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Select School"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Please select your exact school name:"),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedSchool,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: _schools
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedSchool = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (selectedSchool != null && _user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(_user!.uid)
                        .update({'school': selectedSchool});
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CITY EDITING ---
  Future<void> _showEditCityDialog(String? currentCity) async {
    final TextEditingController cityController =
        TextEditingController(text: currentCity);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Location"),
        content: TextField(
          controller: cityController,
          decoration: const InputDecoration(
              labelText: "City", hintText: "e.g. Amsterdam"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (cityController.text.isNotEmpty && _user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user!.uid)
                    .update({'city': cityController.text.trim()});
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- ADD EXPERIENCE MODAL ---
  void _showAddExperienceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const AddExperienceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Center(child: Text("Not logged in."));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text("No profile data.",
                    style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!.data();
          final List<String> skills =
              data?['tags'] != null ? List<String>.from(data!['tags']) : [];
          final List<dynamic> experiences = data?['experience'] ?? [];

          final String name =
              data?['displayName'] ?? _user!.displayName ?? "No Name";
          final String city = data?['city'] ?? "No location set";
          final String school = data?['school'] ?? "No school selected";
          final String role = data?['role'] ?? "Student";
          final String bio = data?['bio'] ?? "";
          final String portfolio = data?['portfolioUrl'] ?? "";

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue)),
                        ),
                        const SizedBox(height: 12),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(role.toUpperCase(),
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.accentGold.withValues(alpha: 0.8),
                                letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Info Cards (School & City) ---
                  Row(
                    children: [
                      Expanded(
                          child: _buildInfoCard(Icons.school, "School", school,
                              () => _showEditSchoolDialog(school))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildInfoCard(Icons.location_on, "City", city,
                              () => _showEditCityDialog(city))),
                    ],
                  ),

                  // --- Bio ---
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text("About Me",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(bio,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.4)),
                  ],

                  // --- Portfolio ---
                  if (portfolio.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        // TODO: Open URL
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: AppColors.accentGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(portfolio,
                                style: const TextStyle(
                                    color: AppColors.accentGold,
                                    decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    )
                  ],

                  const Divider(color: Colors.white24, height: 40),

                  // --- Experience Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Experience",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: AppColors.accentGold),
                        onPressed: _showAddExperienceModal,
                      ),
                    ],
                  ),
                  if (experiences.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("No experience added yet.",
                          style: TextStyle(
                              color: Colors.white54,
                              fontStyle: FontStyle.italic)),
                    ),
                  ...experiences.map((exp) {
                    final e = exp as Map<String, dynamic>;
                    return Card(
                      color: Colors.white.withValues(alpha: 0.1),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e['company'] ?? 'Unknown',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                if (e['duration'] != null && e['duration'] != 'N/A')
                                  Chip(
                                    label: Text(e['duration'] ?? '',
                                        style: const TextStyle(fontSize: 10)),
                                    backgroundColor: AppColors.accentGold,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            if (e['description'] != null) ...[
                              const SizedBox(height: 8),
                              Text(e['description'],
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8))),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: (e['tags'] as List<dynamic>? ?? [])
                                  .map((t) => Text("#$t",
                                      style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 12)))
                                  .toList(),
                            )
                          ],
                        ),
                      ),
                    );
                  }),

                  const Divider(color: Colors.white24, height: 40),

                  // --- Skills Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Skills",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.tags),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: skills
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.white.withAlpha(230),
                              labelStyle: const TextStyle(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w600),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accentGold, size: 16),
                const SizedBox(width: 4),
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- SEPARATE WIDGET FOR ADDING EXPERIENCE ---
class AddExperienceSheet extends StatefulWidget {
  const AddExperienceSheet({super.key});

  @override
  State<AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<AddExperienceSheet> {
  final _companyController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedDuration = '6 Months';
  List<String> _availableTags = [];
  List<String> _selectedTags = [];
  bool _isLoadingTags = true;

  final List<String> _durations = [
    '< 3 Months',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years+'
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final String response = await rootBundle.loadString('assets/tags.json');
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _availableTags = data.cast<String>();
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading tags: $e");
    }
  }

  void _saveExperience() async {
    if (_companyController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newExperience = {
        'company': _companyController.text.trim(),
        'description': _descController.text.trim(),
        'duration': _selectedDuration,
        'tags': _selectedTags,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'experience': FieldValue.arrayUnion([newExperience])
      });
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          const Text("Add Work Experience",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _companyController,
            decoration: const InputDecoration(
                labelText: "Company Name", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
           TextField(
            controller: _descController,
            decoration: const InputDecoration(
                labelText: "Description", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedDuration,
            decoration: const InputDecoration(
                labelText: "Duration", border: OutlineInputBorder()),
            items: _durations
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) => setState(() => _selectedDuration = val!),
          ),
          const SizedBox(height: 16),
          const Text("Technologies Used:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4)),
            child: _isLoadingTags
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: InlineChoice<String>.multiple(
                      clearable: true,
                      value: _selectedTags,
                      onChanged: (val) => setState(() => _selectedTags = val),
                      itemCount: _availableTags.length,
                      itemBuilder: (state, i) {
                        return ChoiceChip(
                          label: Text(_availableTags[i]),
                          selected: state.selected(_availableTags[i]),
                          onSelected: state.onSelected(_availableTags[i]),
                          selectedColor: AppColors.accentGold,
                          backgroundColor: Colors.white, // Changed from default/transparent which might look bad
                          // Fixed Text Color visibility issue
                          labelStyle: TextStyle(
                            color: state.selected(_availableTags[i]) 
                                ? AppColors.darkBlue 
                                : AppColors.darkBlue, // Ensure text is visible on white background
                          ),
                        );
                      },
                      listBuilder:
                          ChoiceList.createWrapped(spacing: 8, runSpacing: 8),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: Colors.white),
              onPressed: _saveExperience,
              child: const Text("Add Experience"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
