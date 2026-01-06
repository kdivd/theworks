import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:choice/choice.dart';
import 'package:theworks/routes.dart';
import 'package:theworks/theme/app_colors.dart';
import 'package:theworks/widgets/app_text_field.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final List<String>? selectedTags;

  const AdditionalInfoScreen({super.key, this.selectedTags});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // School Logic
  String? _selectedSchool;
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

  // Work Experience Logic
  bool _hasExperience = false;
  final List<Map<String, dynamic>> _experiences = [];

  // Temporary controllers for the "Add Experience" form
  final TextEditingController _expCompanyController = TextEditingController();
  final TextEditingController _expDescController = TextEditingController();
  String _expDuration = '6 Months'; // Default duration
  List<String> _expSelectedTags = [];

  final List<String> _durations = [
    '< 3 Months',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years+'
  ];

  List<String> _availableTags = [];
  bool _isLoading = false;
  bool _isAddingExperience = false; // To toggle the "Add Form" visibility

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
        });
      }
    } catch (e) {
      debugPrint("Error loading tags: $e");
    }
  }

  void _addExperienceToList() {
    if (_expCompanyController.text.trim().isEmpty) return;

    setState(() {
      _experiences.add({
        'company': _expCompanyController.text.trim(),
        'description': _expDescController.text.trim(),
        'duration': _expDuration,
        'tags': List<String>.from(_expSelectedTags),
      });

      // Reset form
      _expCompanyController.clear();
      _expDescController.clear();
      _expDuration = '6 Months';
      _expSelectedTags = [];
      _isAddingExperience = false;
    });
  }

  void _removeExperience(int index) {
    setState(() {
      _experiences.removeAt(index);
    });
  }

  Future<void> _onComplete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your school')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // If the form is open and filled but not added, add it automatically
      if (_isAddingExperience && _expCompanyController.text.isNotEmpty) {
        _experiences.add({
          'company': _expCompanyController.text.trim(),
          'description': _expDescController.text.trim(),
          'duration': _expDuration,
          'tags': List<String>.from(_expSelectedTags),
        });
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'school': _selectedSchool,
        'city': _locationController.text.trim(),
        'portfolioUrl': _portfolioController.text.trim(),
        'bio': _bioController.text.trim(),
        'experience': _experiences, // Save the list of maps
        // Legacy fields cleanup
        'hasExperience': _hasExperience,
      }, SetOptions(merge: true));

      if (!mounted) return;

      // Navigate to Home
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: {'selectedTags': widget.selectedTags},
      );
    } catch (e) {
      debugPrint('Error saving additional info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving info: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _portfolioController.dispose();
    _bioController.dispose();
    _expCompanyController.dispose();
    _expDescController.dispose();
    super.dispose();
  }

  // Helper for gold section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.accentGold,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        title:
            const Text('One Last Step', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accentGold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile Details",
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "These details help recruiters find you.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // --- School ---
                    _buildSectionTitle("School"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF303A5A),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSchool,
                          hint: const Text("Select your school",
                              style: TextStyle(color: Colors.white70)),
                          isExpanded: true,
                          dropdownColor: const Color(0xFF303A5A),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white70),
                          items: _schools.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedSchool = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Location ---
                    _buildSectionTitle("Current City"),
                    const SizedBox(height: 8),
                    AppTextField(
                      hint: "e.g. Rotterdam",
                      controller: _locationController,
                    ),
                    const SizedBox(height: 20),

                    // --- Portfolio ---
                    _buildSectionTitle("Portfolio / Website"),
                    const SizedBox(height: 8),
                    AppTextField(
                      hint: "https://...",
                      controller: _portfolioController,
                    ),
                    const SizedBox(height: 20),

                    // --- Bio ---
                    _buildSectionTitle("About Me"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF303A5A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _bioController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Short bio...",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),

                    // --- Work Experience ---
                    SwitchListTile(
                      activeTrackColor: AppColors.accentGold,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Do you have prior work experience?",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      value: _hasExperience,
                      onChanged: (val) {
                        setState(() {
                          _hasExperience = val;
                          if (val && _experiences.isEmpty) {
                            _isAddingExperience = true;
                          } else if (!val) {
                            _isAddingExperience = false;
                          }
                        });
                      },
                    ),

                    if (_hasExperience) ...[
                      // List of added experiences
                      ..._experiences.asMap().entries.map((entry) {
                        final index = entry.key;
                        final exp = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    exp['company'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 20),
                                    onPressed: () => _removeExperience(index),
                                  ),
                                ],
                              ),
                              // Show Duration in list
                              if (exp['duration'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "Duration: ${exp['duration']}",
                                    style: const TextStyle(
                                        color: AppColors.accentGold,
                                        fontSize: 12),
                                  ),
                                ),
                              if (exp['description'] != null &&
                                  exp['description'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(exp['description'],
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                ),
                              Wrap(
                                spacing: 6,
                                children: (exp['tags'] as List<String>)
                                    .map((t) => Chip(
                                          label: Text(t,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          backgroundColor: AppColors.accentGold,
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Add New Form
                      if (_isAddingExperience)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF303A5A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Add Experience",
                                  style: TextStyle(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              AppTextField(
                                hint: "Company Name",
                                controller: _expCompanyController,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  controller: _expDescController,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Description (Role, tasks...)",
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Duration Dropdown
                              const Text("Duration:",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 5),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _expDuration,
                                    isExpanded: true,
                                    dropdownColor: AppColors.darkBlue,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.white70),
                                    items: _durations.map((d) {
                                      return DropdownMenuItem(
                                        value: d,
                                        child: Text(d,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null)
                                        setState(() => _expDuration = val);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              const Text("Technologies used at this job:",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 5),

                              // Chips Choice
                              SizedBox(
                                height: 150,
                                child: SingleChildScrollView(
                                  child: InlineChoice<String>.multiple(
                                    clearable: true,
                                    value: _expSelectedTags,
                                    onChanged: (val) =>
                                        setState(() => _expSelectedTags = val),
                                    itemCount: _availableTags.length,
                                    itemBuilder: (state, i) {
                                      return ChoiceChip(
                                        label: Text(_availableTags[i]),
                                        selected:
                                            state.selected(_availableTags[i]),
                                        onSelected:
                                            state.onSelected(_availableTags[i]),
                                        selectedColor: AppColors.offWhite,
                                        backgroundColor: AppColors.accentGold,
                                        // Keep dark background
                                        // Change text color: Gold when unselected (so it's visible), Dark Blue when selected
                                        labelStyle: TextStyle(
                                          color:
                                              state.selected(_availableTags[i])
                                                  ? AppColors.darkBlue
                                                  : AppColors.darkBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                    listBuilder: ChoiceList.createWrapped(
                                      spacing: 8,
                                      runSpacing: 8,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_experiences.isNotEmpty)
                                    TextButton(
                                      onPressed: () => setState(
                                          () => _isAddingExperience = false),
                                      child: const Text("Cancel"),
                                    ),
                                  ElevatedButton(
                                    onPressed: _addExperienceToList,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentGold,
                                      foregroundColor: AppColors.darkBlue,
                                    ),
                                    child: const Text("Add"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      else
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _isAddingExperience = true),
                          icon: const Icon(Icons.add,
                              color: AppColors.accentGold),
                          label: const Text("Add Another Position",
                              style: TextStyle(color: AppColors.accentGold)),
                        ),
                    ],

                    const SizedBox(height: 40),

                    // Finish Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: _onComplete,
                        child: const Text(
                          'Finish Setup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
