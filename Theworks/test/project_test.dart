import 'package:flutter_test/flutter_test.dart';
import 'package:theworks/classes/project.dart';

void main() {
  test('Project model should handle companyName', () {
    final project = Project(
      id: '1',
      name: 'Test Project',
      description: 'Desc',
      tags: ['tag1'],
      createdBy: 'user1',
      companyName: 'Test Company',
      duration: '1 Month',
      locationType: 'Remote',
      city: 'NY',
    );

    expect(project.companyName, 'Test Company');

    final map = project.toMap();
    expect(map['companyName'], 'Test Company');

    final fromMap = Project.fromMap(map, '1');
    expect(fromMap.companyName, 'Test Company');
  });

  test('Project toMap should generate lowercase searchTags', () {
    final project = Project(
      name: 'Test Project',
      description: 'Desc',
      tags: ['Tag1', 'TAG2', 'tag3'],
      duration: '1 Month',
      locationType: 'Remote',
      city: 'NY',
    );

    final map = project.toMap();
    expect(map['searchTags'], containsAll(['tag1', 'tag2', 'tag3']));
    expect(map['searchTags'].length, 3);
  });
}
