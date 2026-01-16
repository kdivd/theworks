import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theworks/classes/project.dart';
import 'package:theworks/classes/project_service.dart';
import 'package:theworks/theme/app_colors.dart';
import 'package:theworks/routes.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _cityController = TextEditingController();

  List<String> _availableTags = [];
  final List<String> _selectedTags = [];
  bool _isLoadingTags = true;
  bool _isUploading = false;

  String _selectedDuration = '3 Months';
  String _selectedLocationType = 'On-site';

  final List<String> _durations = ['1 Month', '3 Months', '6 Months', '1 Year'];
  final List<String> _locationTypes = ['On-site', 'Remote', 'Hybrid'];

  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['companyLocation'] != null) {
        _cityController.text = args['companyLocation'];
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _cityController.dispose();
    super.dispose();
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
      debugPrint('Error loading tags: $e');
      if (mounted) setState(() => _isLoadingTags = false);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one tag")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final newProject = Project(
        name: _titleController.text.trim(),
        description: _descController.text.trim(),
        tags: _selectedTags,
        createdBy: user?.uid,
        duration: _selectedDuration,
        locationType: _selectedLocationType,
        city: _cityController.text.trim(),
      );

      await ProjectService().createProject(newProject);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project created successfully!")),
      );

      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final fromOnboarding = args?['fromOnboarding'] == true;

      if (fromOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text("Post New Project"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Project Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (v) => v!.isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDuration,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _durations.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedDuration = newValue!);
                },
              ),
              const SizedBox(height: 16),
              const Text("Location Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _locationTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _selectedLocationType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLocationType = type);
                      }
                    },
                    selectedColor: AppColors.accentGold,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("Required Skills (Tags)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (_isLoadingTags)
                const Center(child: CircularProgressIndicator())
              else if (_availableTags.isEmpty)
                const Text("No tags found.")
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (_) => _toggleTag(tag),
                        backgroundColor: Colors.grey[100],
                        selectedColor: AppColors.accentGold,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? AppColors.darkBlue : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        checkmarkColor: AppColors.darkBlue,
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isUploading ? null : _submitProject,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Project",
                          style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
