class Project {
  final String? id;
  final String name;
  final String description;
  final List<String> tags;
  final String? createdBy;
  final String? companyName;
  final String duration;
  final String locationType;
  final String city;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.createdBy,
    this.companyName,
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
      'companyName': companyName,
      'duration': duration,
      'locationType': locationType,
      'city': city,
      'searchTags': tags.map((t) => t.toLowerCase()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map, String docId) {
    return Project(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdBy: map['createdBy'],
      companyName: map['companyName'],
      duration: map['duration'] ?? '',
      locationType: map['locationType'] ?? 'On-site',
      city: map['city'] ?? 'Unknown',
    );
  }
}
