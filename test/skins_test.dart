import 'package:flutter_test/flutter_test.dart';

import 'package:flipclock/theme/skins.dart';

void main() {
  test('every skin has its own id and its own display name', () {
    final ids = allSkins.map((s) => s.id).toList();
    final names = allSkins.map((s) => s.name).toList();

    // A duplicate id would silently hand two skins the same saved setting.
    expect(ids.toSet().length, ids.length);
    expect(names.toSet().length, names.length);
    for (final s in allSkins) {
      expect(s.id, isNotEmpty);
      expect(s.name, isNotEmpty);
    }
  });
}
