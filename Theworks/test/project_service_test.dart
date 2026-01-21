import 'package:flutter_test/flutter_test.dart';
import 'package:theworks/classes/project_service.dart';

void main() {
  group('ProjectService Logic', () {
    // No instantiation needed

    test('expandTags should lowercase input tags', () {
      final tags = ['Flutter', 'DART'];
      final expanded = ProjectService.expandTags(tags);
      expect(expanded, containsAll(['flutter', 'dart']));
    });

    test('expandTags should expand "front-end" to implied tags', () {
      final tags = ['front-end'];
      final expanded = ProjectService.expandTags(tags);
      
      // Direct implications
      expect(expanded, containsAll(['front-end', 'javascript', 'html', 'css', 'react', 'flutter']));
    });

    test('expandTags should recursively expand "full stack"', () {
      final tags = ['full stack'];
      final expanded = ProjectService.expandTags(tags);

      // Should include front-end and back-end implications
      expect(expanded, contains('front-end'));
      expect(expanded, contains('back-end'));
      
      // Deep implications
      expect(expanded, contains('javascript')); // from front-end
      expect(expanded, contains('python')); // from back-end
      expect(expanded, contains('sql')); // from back-end
    });

    test('expandTags should handle mixed tags and deduplicate', () {
      final tags = ['front-end', 'javascript']; // javascript is already implied by front-end
      final expanded = ProjectService.expandTags(tags);

      expect(expanded, contains('html'));
      expect(expanded.where((t) => t == 'javascript').length, 1);
    });
  });
}
