class Project {
  final String? id;
  final String name;
  final String description;
  final List<String> tags;
  final String? createdBy;
  final String duration;
  final String locationType;
  final String city;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.createdBy,
    required this.duration,
    required this.locationType,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'tags': tags,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'createdBy': createdBy,
      'duration': duration,
      'locationType': locationType,
      'city': city,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map, String docId) {
    return Project(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdBy: map['createdBy'],
      duration: map['duration'] ?? '',
      locationType: map['locationType'] ?? 'On-site',
      city: map['city'] ?? 'Unknown',
    );
  }
}
