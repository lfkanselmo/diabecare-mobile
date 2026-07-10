import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Una acción seleccionable de un action sheet adaptativo.
class PlatformAction<T> {
  const PlatformAction({required this.label, required this.value, this.isDestructive = false, this.icon});

  final String label;
  final T value;
  final bool isDestructive;
  final IconData? icon;
}

/// Bottom sheet Material en Android, popup modal Cupertino en iOS — mismo
/// principio "adaptativo, no genérico" de DESIGN_GUIDELINES.md sección 1.
Future<T?> showPlatformActionSheet<T>({
  required BuildContext context,
  required List<PlatformAction<T>> actions,
  String? title,
  PlatformAction<T>? cancelAction,
}) {
  if (Platform.isIOS) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: title == null ? null : Text(title),
        actions: [
          for (final action in actions)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(action.value),
              isDestructiveAction: action.isDestructive,
              child: Text(action.label),
            ),
        ],
        cancelButton: cancelAction == null
            ? null
            : CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(cancelAction.value),
                child: Text(cancelAction.label),
              ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
          for (final action in actions)
            ListTile(
              leading: action.icon == null ? null : Icon(action.icon),
              title: Text(
                action.label,
                style: action.isDestructive
                    ? TextStyle(color: Theme.of(context).colorScheme.error)
                    : null,
              ),
              onTap: () => Navigator.of(context).pop(action.value),
            ),
        ],
      ),
    ),
  );
}
