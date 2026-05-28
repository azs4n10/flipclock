import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/fonts.dart';
import '../theme/skin.dart';
import '../theme/skins.dart';
import 'custom_color_screen.dart';

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
          'Appearance',
          style: TextStyle(
            color: skin.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Skin', skin: skin),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.4,
            ),
            itemCount: allSkins.length + 1,
            itemBuilder: (context, i) {
              if (i == allSkins.length) {
                // The editable "Custom" skin, built from the user's colors.
                return _SkinTile(
                  skin: state.isCustomSkin
                      ? skin
                      : Skin(
                          id: 'custom',
                          name: 'Custom',
                          background: state.customBg,
                          cardBackground: state.customCard,
                          digitColor: state.customDigit,
                          accentColor: state.customAccent,
                          buttonColor: state.customAccent,
                          buttonTextColor: Colors.white,
                          primaryTextColor: state.customDigit,
                          subTextColor: state.customDigit,
                          dividerColor: state.customCard,
                        ),
                  selected: state.isCustomSkin,
                  trailingEdit: true,
                  onTap: () {
                    state.setSkinId('custom');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomColorScreen(),
                      ),
                    );
                  },
                );
              }
              final s = allSkins[i];
              return _SkinTile(
                skin: s,
                selected: s.id == skin.id,
                onTap: () => state.setSkin(s),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('Number font', skin: skin),
          const SizedBox(height: 4),
          Text(
            "The 8 styles from iPhone's lock screen",
            style: TextStyle(color: skin.subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: allFonts.length,
            itemBuilder: (context, i) {
              final f = allFonts[i];
              return _FontTile(
                font: f,
                skin: skin,
                selected: f.id == state.font.id,
                onTap: () => state.setFont(f),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('Text font', skin: skin),
          const SizedBox(height: 4),
          Text(
            'For the date, labels and signature',
            style: TextStyle(color: skin.subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final tf in textFonts)
                _TextFontChip(
                  tf: tf,
                  skin: skin,
                  selected: tf.id == state.textFontId,
                  onTap: () => state.setTextFont(tf.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextFontChip extends StatelessWidget {
  const _TextFontChip({
    required this.tf,
    required this.skin,
    required this.selected,
    required this.onTap,
  });

  final TextFont tf;
  final Skin skin;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? skin.buttonColor : skin.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? skin.buttonColor : skin.dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          tf.name,
          style: tf.style(
            fontSize: 18,
            color: selected ? skin.buttonTextColor : skin.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.skin});

  final String title;
  final Skin skin;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: skin.primaryTextColor,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.selected,
    required this.onTap,
    this.trailingEdit = false,
  });

  final Skin skin;
  final bool selected;
  final VoidCallback onTap;
  final bool trailingEdit;

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
                child: Stack(
                  children: [
                    Center(
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
                    if (trailingEdit)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Icon(Icons.edit,
                            size: 16, color: skin.digitColor),
                      ),
                  ],
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

class _FontTile extends StatelessWidget {
  const _FontTile({
    required this.font,
    required this.skin,
    required this.selected,
    required this.onTap,
  });

  final DigitFont font;
  final Skin skin;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: skin.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? skin.buttonColor : skin.dividerColor,
            width: selected ? 3 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  child: Text('12', style: font.build(48, skin.digitColor)),
                ),
              ),
            ),
            Text(
              font.name,
              style: TextStyle(
                color: skin.primaryTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
