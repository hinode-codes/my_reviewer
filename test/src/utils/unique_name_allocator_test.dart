import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/utils/unique_name_allocator.dart';

void main() {
  group('UniqueNameAllocator', () {
    test('a free name is handed out as is', () {
      expect(UniqueNameAllocator(const []).claim('Page'), 'Page');
    });

    test('repeated claims get numbered from 2', () {
      final names = UniqueNameAllocator(const []);

      expect(names.claim('Page'), 'Page');
      expect(names.claim('Page'), 'Page_2');
      expect(names.claim('Page'), 'Page_3');
    });

    test('names already taken are skipped', () {
      final names = UniqueNameAllocator(const ['Page', 'Page_2']);

      expect(names.claim('Page'), 'Page_3');
    });

    test('collisions ignore case, as on iOS', () {
      final names = UniqueNameAllocator(const ['Page']);

      expect(names.claim('page'), 'page_2');
      expect(names.claim('PAGE'), 'PAGE_3');
    });

    test('the returned name keeps the case it was asked for', () {
      expect(UniqueNameAllocator(const []).claim('My Notes'), 'My Notes');
    });

    test('a numbered name claimed directly is not handed out again', () {
      final names = UniqueNameAllocator(const []);

      expect(names.claim('Page_2'), 'Page_2');
      expect(names.claim('Page'), 'Page');
      expect(names.claim('Page'), 'Page_3');
    });

    test('the same base with different extensions does not collide', () {
      final names = UniqueNameAllocator(const []);

      expect(names.claim('Page', extension: 'jpg'), 'Page');
      expect(names.claim('Page', extension: 'png'), 'Page');
    });

    test('extensions compare ignoring case too', () {
      final names = UniqueNameAllocator(const []);

      expect(names.claim('Page', extension: 'jpg'), 'Page');
      expect(names.claim('Page', extension: 'JPG'), 'Page_2');
    });

    test('taken names must be given in the form they are claimed in', () {
      // "page.jpg" is taken; claiming "page" with that extension collides,
      // claiming bare "page" does not.
      final names = UniqueNameAllocator(const ['page.jpg']);

      expect(names.claim('page', extension: 'jpg'), 'page_2');
      expect(names.claim('page'), 'page');
    });
  });
}