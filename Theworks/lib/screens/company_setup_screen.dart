import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/routes.dart';
import 'package:theworks/theme/app_colors.dart';
import 'package:choice/choice.dart';

class CompanySetupScreen extends StatefulWidget {
  const CompanySetupScreen({super.key});

  @override
  State<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends State<CompanySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();

  List<String> _availableTags = [];
  List<String> _selectedTags = [];
  bool _isLoadingTags = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descController.dispose();
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

  Future<void> _saveCompanyProfile({bool createProject = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'companyName': _nameController.text.trim(),
        'companyLocation': _locationController.text.trim(),
        'city': _locationController.text.trim(), // Save city as well
        'companyDescription': _descController.text.trim(),
        'techStack': _selectedTags,
        // We ensure the role is recruiter, just in case
        'role': 'recruiter',
      }, SetOptions(merge: true));

      if (!mounted) return;

      if (createProject) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.createProject,
          arguments: {
            'fromOnboarding': true,
            'companyLocation': _locationController.text.trim(),
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Error saving company profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        title: const Text('Company Setup'),
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tell us about your company",
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This information will be visible to students.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Company Name
                const Text("Company Name",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('e.g. Tech Solutions Inc.'),
                  validator: (v) =>
                      v!.isEmpty ? 'Company name is required' : null,
                ),
                const SizedBox(height: 16),

                // Location
                const Text("Location",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('e.g. Amsterdam, Netherlands'),
                  validator: (v) => v!.isEmpty ? 'Location is required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                const Text("Description",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                      'Tell us about your company culture, mission, etc...'),
                  validator: (v) =>
                      v!.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),

                // Tech Stack
                const Text("Tech Stack / Languages",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Select the technologies your company uses.",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),

                if (_isLoadingTags)
                  const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentGold))
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
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
                          backgroundColor: Colors.white24,
                          labelStyle: TextStyle(
                            color: state.selected(_availableTags[i])
                                ? AppColors.darkBlue
                                : Colors.white,
                            fontWeight: state.selected(_availableTags[i])
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      },
                      listBuilder: ChoiceList.createWrapped(
                        spacing: 8,
                        runSpacing: 8,
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () => _saveCompanyProfile(createProject: false),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text(
                            'Finish Setup',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentGold,
                      side: const BorderSide(color: AppColors.accentGold),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () => _saveCompanyProfile(createProject: true),
                    child: const Text(
                      'Finish & Create First Project',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF303A5A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
