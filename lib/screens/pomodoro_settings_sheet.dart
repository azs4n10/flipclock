import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_actions.dart';
import '../services/bgm.dart';
import '../state/app_state.dart';
import '../theme/skin.dart';

class PomodoroSettingsSheet extends StatelessWidget {
  const PomodoroSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final skin = state.skin;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: skin.dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: skin.primaryTextColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close, color: skin.primaryTextColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
            _SectionLabel('Display', skin: skin),
            _ToggleTile(
              label: '24-hour clock',
              value: state.use24Hour,
              onChanged: state.setUse24Hour,
              skin: skin,
            ),
            _ToggleTile(
              label: 'Show seconds',
              value: state.showSeconds,
              onChanged: state.setShowSeconds,
              skin: skin,
            ),
            _ToggleTile(
              label: 'Show date',
              value: state.showDate,
              onChanged: state.setShowDate,
              skin: skin,
            ),
            _ToggleTile(
              label: 'Seasonal effect',
              value: state.seasonalEffect,
              onChanged: state.setSeasonalEffect,
              skin: skin,
            ),
            _SignatureTile(
              value: state.signature,
              onChanged: state.setSignature,
              skin: skin,
            ),
            _NumberTile(
              label: 'Font size',
              value: (state.fontScale * 100).round(),
              min: 80,
              max: 140,
              step: 10,
              onChanged: (v) => state.setFontScale(v / 100),
              suffix: '%',
              skin: skin,
            ),
            const SizedBox(height: 12),
            _SectionLabel('Sound (BGM)', skin: skin),
            for (final t in bgmTracks)
              _RadioTile(
                label: t.name,
                selected: state.bgmId == t.id,
                onTap: () => state.setBgm(t.id),
                skin: skin,
              ),
            const SizedBox(height: 12),
            _SectionLabel('Pomodoro', skin: skin),
            _ToggleTile(
              label: 'Remind sound',
              value: state.remindSoundEnabled,
              onChanged: state.setRemindSoundEnabled,
              skin: skin,
            ),
            _ToggleTile(
              label: 'Vibration',
              value: state.vibrationEnabled,
              onChanged: state.setVibrationEnabled,
              skin: skin,
            ),
            _NumberTile(
              label: 'Focus length (min)',
              value: state.focusMinutes,
              min: 5,
              max: 95, // keep within the 2-digit MM display (no HH needed)
              step: 5,
              onChanged: state.setFocusMinutes,
              skin: skin,
            ),
            _NumberTile(
              label: 'Short break (min)',
              value: state.shortBreakMinutes,
              min: 1,
              max: 30,
              step: 1,
              onChanged: state.setShortBreakMinutes,
              skin: skin,
            ),
            _NumberTile(
              label: 'Long break (min)',
              value: state.longBreakMinutes,
              min: 5,
              max: 60,
              step: 5,
              onChanged: state.setLongBreakMinutes,
              skin: skin,
            ),
            _NumberTile(
              label: 'Long break every',
              value: state.longBreakInterval,
              min: 2,
              max: 8,
              step: 1,
              onChanged: state.setLongBreakInterval,
              suffix: 'focus',
              skin: skin,
            ),
            const SizedBox(height: 12),
            _SectionLabel('More', skin: skin),
            _ActionTile(
              label: 'Share',
              icon: Icons.ios_share,
              onTap: AppActions.share,
              skin: skin,
            ),
            _ActionTile(
              label: 'Send feedback',
              icon: Icons.mail_outline,
              onTap: AppActions.feedback,
              skin: skin,
            ),
            _ActionTile(
              label: 'Rate us',
              icon: Icons.star_outline,
              onTap: AppActions.rate,
              skin: skin,
            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.skin});

  final String text;
  final Skin skin;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: skin.subTextColor,
          ),
        ),
      ),
    );
  }
}

class _SignatureTile extends StatelessWidget {
  const _SignatureTile({
    required this.value,
    required this.onChanged,
    required this.skin,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final Skin skin;

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: value);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: skin.cardBackground,
        title: Text('Signature',
            style: TextStyle(color: skin.primaryTextColor)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          style: TextStyle(color: skin.primaryTextColor),
          cursorColor: skin.buttonColor,
          decoration: InputDecoration(
            hintText: 'take your time',
            hintStyle: TextStyle(color: skin.subTextColor),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: skin.subTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child:
                Text('OK', style: TextStyle(color: skin.buttonColor)),
          ),
        ],
      ),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _edit(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text('Signature',
                  style: TextStyle(
                      fontSize: 15, color: skin.primaryTextColor)),
            ),
            Flexible(
              child: Text(
                value.isEmpty ? '(none)' : value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14, color: skin.subTextColor),
              ),
            ),
            Icon(Icons.chevron_right, color: skin.subTextColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.skin,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Skin skin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? skin.digitColor : skin.subTextColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: skin.primaryTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.skin,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Skin skin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: skin.accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: skin.primaryTextColor),
              ),
            ),
            Icon(Icons.chevron_right, color: skin.subTextColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.skin,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Skin skin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: skin.primaryTextColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            // Material 3 ignores activeThumbColor for the knob, so set the
            // thumb explicitly via a state resolver: digit color when on.
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? skin.digitColor
                  : skin.subTextColor,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? skin.buttonColor
                  : skin.cardBackground,
            ),
            trackOutlineColor: WidgetStateProperty.all(skin.dividerColor),
          ),
        ],
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    required this.skin,
    this.suffix,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;
  final Skin skin;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: skin.primaryTextColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: skin.accentColor),
            onPressed: value > min ? () => onChanged(value - step) : null,
          ),
          SizedBox(
            width: 54,
            child: Text(
              suffix == null ? '$value' : '$value $suffix',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: skin.digitColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: skin.accentColor),
            onPressed: value < max ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }
}
