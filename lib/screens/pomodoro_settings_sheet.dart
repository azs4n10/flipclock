import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: skin.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              'Pomodoro Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: skin.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
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
              max: 120,
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
            activeThumbColor: skin.buttonColor,
            activeTrackColor: skin.accentColor,
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
