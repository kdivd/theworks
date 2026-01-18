import 'package:flutter/material.dart';
import 'package:theworks/theme/app_colors.dart';

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final String role = userData['role'] ?? 'student';
    final bool isRecruiter = role == 'recruiter';
    final String name = isRecruiter
        ? (userData['companyName'] ?? userData['displayName'] ?? 'Unknown Company')
        : (userData['displayName'] ?? 'Unknown User');
    final String subtitle = isRecruiter ? 'Company' : 'Student';
    final String location = isRecruiter
        ? (userData['companyLocation'] ?? userData['city'] ?? 'Unknown Location')
        : (userData['city'] ?? 'Unknown Location');
    final String bio = isRecruiter 
        ? (userData['companyDescription'] ?? '')
        : (userData['bio'] ?? '');
    final List<dynamic> skills = isRecruiter 
        ? (userData['techStack'] ?? []) 
        : (userData['tags'] ?? []);
    
    // For students: school, experience
    final String school = userData['school'] ?? 'Unknown School';
    final List<dynamic> experience = userData['experience'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.darkBlue,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Bio / Description
            if (bio.isNotEmpty) ...[
              Text(
                isRecruiter ? 'About Company' : 'Bio',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
              ),
              const SizedBox(height: 8),
              Text(bio, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
            ],

            // Student Specific: School
            if (!isRecruiter) ...[
              const Text(
                'School',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
              ),
              const SizedBox(height: 8),
              Text(school, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
            ],

            // Skills / Tech Stack
            if (skills.isNotEmpty) ...[
              Text(
                isRecruiter ? 'Tech Stack' : 'Skills',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((s) => Chip(
                  label: Text(s.toString()),
                  backgroundColor: AppColors.accentGold,
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Student Specific: Experience
            if (!isRecruiter && experience.isNotEmpty) ...[
              const Text(
                'Experience',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
              ),
              const SizedBox(height: 8),
              ...experience.map((exp) {
                final e = exp as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(e['company'] ?? 'Unknown Company', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(e['description'] ?? ''),
                         if (e['duration'] != null) Text(e['duration'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
