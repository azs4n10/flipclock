import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/skin.dart';

class CustomColorScreen extends StatelessWidget {
  const CustomColorScreen({super.key});

  Future<void> _pick(
    BuildContext context,
    String title,
    Color current,
    ValueChanged<Color> onPicked,
  ) async {
    var temp = current;
    final result = await showDialog<Color>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, temp),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null) onPicked(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final skin = state.skin; // custom skin (selected on entry)

    return Scaffold(
      backgroundColor: skin.background,
      appBar: AppBar(
        backgroundColor: skin.background,
        elevation: 0,
        iconTheme: IconThemeData(color: skin.primaryTextColor),
        title: Text(
          'Custom color',
          style: TextStyle(
            color: skin.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Live preview
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: skin.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: skin.dividerColor),
            ),
            child: Center(
              child: Container(
                width: 150,
                height: 110,
                decoration: BoxDecoration(
                  color: skin.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '12',
                        style: TextStyle(
                          color: skin.digitColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 64,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(height: 2, color: skin.dividerColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ColorRow(
            label: 'Background',
            color: state.customBg,
            skin: skin,
            onTap: () => _pick(context, 'Background', state.customBg,
                (c) => state.setCustomColors(bg: c)),
          ),
          _ColorRow(
            label: 'Card',
            color: state.customCard,
            skin: skin,
            onTap: () => _pick(context, 'Card', state.customCard,
                (c) => state.setCustomColors(card: c)),
          ),
          _ColorRow(
            label: 'Numbers',
            color: state.customDigit,
            skin: skin,
            onTap: () => _pick(context, 'Numbers', state.customDigit,
                (c) => state.setCustomColors(digit: c)),
          ),
          _ColorRow(
            label: 'Accent (tabs / buttons)',
            color: state.customAccent,
            skin: skin,
            onTap: () => _pick(context, 'Accent', state.customAccent,
                (c) => state.setCustomColors(accent: c)),
          ),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.label,
    required this.color,
    required this.skin,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Skin skin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: skin.primaryTextColor),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: skin.dividerColor, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: skin.subTextColor, size: 20),
          ],
        ),
      ),
    );
  }
}
