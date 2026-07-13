import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// `SegmentedButton` Material 3 en Android, `CupertinoSlidingSegmentedControl`
/// en iOS — DESIGN_GUIDELINES.md sección 5, fila "Selector de unidad".
class AdaptiveSegmentedControl<T extends Object> extends StatelessWidget {
  const AdaptiveSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSlidingSegmentedControl<T>(
        groupValue: selected,
        children: {
          for (final entry in options.entries)
            entry.key: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        },
        onValueChanged: (value) {
          if (value != null) onChanged(value);
        },
      );
    }

    return SegmentedButton<T>(
      segments: [
        for (final entry in options.entries)
          ButtonSegment(
            value: entry.key,
            label: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
