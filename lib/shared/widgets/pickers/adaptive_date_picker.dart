import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// `showDatePicker` Material en Android, `CupertinoDatePicker` (rueda
/// giratoria) en iOS — DESIGN_GUIDELINES.md sección 5, fila "Selector de
/// fecha/hora". Se necesita tanto para el registro (fecha de nacimiento,
/// fecha de diagnóstico) como para el registro de glucosa en Fase 1.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  if (Platform.isIOS) {
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) {
        var selected = initialDate;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(selected),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  return showDatePicker(context: context, initialDate: initialDate, firstDate: firstDate, lastDate: lastDate);
}
