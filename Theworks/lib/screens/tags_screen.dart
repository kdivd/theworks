import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:choice/choice.dart';
import 'package:theworks/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/theme/app_colors.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  List<String> choices = [];
  List<String> selectedValues = [];
  bool isLoading = true;

  bool _isAdmin = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadChoices();
    await _loadUserTags();
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadChoices() async {
    try {
      final String response = await rootBundle.loadString('assets/tags.json');
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          choices = data.cast<String>();
        });
      }
    } catch (e) {
      debugPrint('Error loading tags JSON: $e');
    }
  }

  Future<void> _loadUserTags() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data();
          if (data != null && data.containsKey('tags')) {
            setState(() {
              selectedValues = List<String>.from(data['tags']);

              if (data['role'] == 'recruiter' || data['role'] == 'admin') {
                _isAdmin = true;
              }
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
  }

  void setSelectedValues(List<String> values) {
    setState(() => selectedValues = values);
  }

  Future<void> _onConfirmPressed() async {
    final navigator = Navigator.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final String roleToSave = _isAdmin ? 'recruiter' : 'student';

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'tags': selectedValues,
        'role': roleToSave,
        'email': user.email,
      }, SetOptions(merge: true));

      if (!mounted) return;
      if (navigator.canPop()) {
        navigator.pop(selectedValues);
      } else {
        navigator.pushReplacementNamed(
          AppRoutes.additionalInfo,
          arguments: selectedValues,
        );
      }
    } catch (e) {
      debugPrint('Error saving tags: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyO) {
          setState(() {
            _isAdmin = !_isAdmin;
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isAdmin
                  ? "Admin Mode Activated! (Role: Recruiter)"
                  : "Admin Mode Disabled (Role: Student)"),
              backgroundColor: _isAdmin ? Colors.green : Colors.red,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBlue,
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accentGold))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isAdmin
                                ? 'Edit Tags (Admin)'
                                : 'Select your skills',
                            style: const TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Tap to select the technologies you know.",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: InlineChoice<String>.multiple(
                        clearable: true,
                        value: selectedValues,
                        onChanged: setSelectedValues,
                        itemCount: choices.length,
                        itemBuilder: (state, i) {
                          final selected = state.selected(choices[i]);
                          return ChoiceChip(
                            selectedColor: AppColors.accentGold,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            labelPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            selected: selected,
                            onSelected: state.onSelected(choices[i]),
                            label: Text(
                              choices[i],
                              style: TextStyle(
                                color: selected
                                    ? AppColors.darkBlue
                                    : Colors.black87,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        listBuilder: ChoiceList.createWrapped(
                          spacing: 10,
                          runSpacing: 10,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.darkBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: _onConfirmPressed,
                            child: Text(
                              Navigator.canPop(context)
                                  ? 'Save Changes'
                                  : 'Confirm & Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
