import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Confirmación de una acción, destructiva o no — `CupertinoActionSheet` con
/// `isDestructiveAction` en iOS, `AlertDialog` Material en Android (ver
/// DESIGN_GUIDELINES.md sección 5, tabla de componentes).
Future<bool> showAdaptiveConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
}) async {
  final confirmed = Platform.isIOS
      ? await showCupertinoModalPopup<bool>(
          context: context,
          builder: (context) => CupertinoActionSheet(
            title: Text(title),
            message: Text(message),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: isDestructive,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
          ),
        )
      : await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: isDestructive
                    ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error)
                    : null,
                child: Text(confirmLabel),
              ),
            ],
          ),
        );

  final result = confirmed ?? false;
  // Feedback háptico solo al confirmar una acción destructiva — ver
  // DESIGN_GUIDELINES.md sección 4 (heavyImpact reservado para
  // confirmaciones destructivas y alertas críticas de glucosa).
  if (result && isDestructive) unawaited(HapticFeedback.heavyImpact());
  return result;
}
