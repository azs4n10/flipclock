import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/skin.dart';
import '../theme/skins.dart';

class SkinPickerScreen extends StatelessWidget {
  const SkinPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final skin = state.skin;
    return Scaffold(
      backgroundColor: skin.background,
      appBar: AppBar(
        backgroundColor: skin.background,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Done',
            style: TextStyle(
              color: skin.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          'Change skin',
          style: TextStyle(
            color: skin.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.4,
        ),
        itemCount: allSkins.length,
        itemBuilder: (context, i) {
          final s = allSkins[i];
          final selected = s.id == skin.id;
          return _SkinTile(
            skin: s,
            selected: selected,
            onTap: () => state.setSkin(s),
          );
        },
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.selected,
    required this.onTap,
  });

  final Skin skin;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: skin.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? skin.buttonColor : skin.dividerColor,
            width: selected ? 3 : 1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: skin.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '12 : 34',
                    style: TextStyle(
                      color: skin.digitColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              skin.name,
              style: TextStyle(
                color: skin.primaryTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
