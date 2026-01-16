import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theworks/classes/post.dart';
import 'package:theworks/classes/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final PostService _postService = PostService();
  List<String> _languageChoices = ['General'];
  String _selectedLanguage = 'General';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      final String response = await rootBundle.loadString('assets/tags.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _languageChoices = ['General', ...data.cast<String>()];
      });
    } catch (e) {
      debugPrint("Error loading tags: $e");
    }
  }

  void setSingleChoice(String? value) {
    setState(() {
      _selectedLanguage = value ?? 'General';
    });
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        
        String authorName = 'Anonymous';
        if (userData != null) {
          if (userData.containsKey('companyName') && userData['companyName'].toString().isNotEmpty) {
            authorName = userData['companyName'];
          } else if (userData.containsKey('displayName') && userData['displayName'].toString().isNotEmpty) {
            authorName = userData['displayName'];
          }
        }
        
        if (authorName == 'Anonymous' && user.displayName != null && user.displayName!.isNotEmpty) {
          authorName = user.displayName!;
        }

        final newPost = Post(
          postId: '', // Firestore will generate this
          authorId: user.uid,
          authorName: authorName,
          title: _titleController.text,
          description: _descriptionController.text,
          language: _selectedLanguage,
          createdAt: Timestamp.now(),
          comments: [],
        );

        await _postService.createPost(newPost);

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
         setState(() {
        _isLoading = false;
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Select a Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _languageChoices.map((lang) {
                        return ChoiceChip(
                          label: Text(lang),
                          selected: _selectedLanguage == lang,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedLanguage = lang;
                              });
                            }
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _selectedLanguage == lang ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createPost,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
