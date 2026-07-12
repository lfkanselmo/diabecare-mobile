import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

/// Mirror de `privacy-policy.component.ts` de la web — mismas 10 secciones,
/// mismo texto (viene de los mismos `es.json`/`en.json` scrapeados por
/// `tool/generate_arb.dart`), incluido el aviso de que es un borrador sin
/// revisión legal todavía. Pública a propósito: el registro enlaza acá
/// antes de que exista sesión (ver `app_router.dart`).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sectionCount = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headings = [
      l10n.legalPrivacyS1Heading,
      l10n.legalPrivacyS2Heading,
      l10n.legalPrivacyS3Heading,
      l10n.legalPrivacyS4Heading,
      l10n.legalPrivacyS5Heading,
      l10n.legalPrivacyS6Heading,
      l10n.legalPrivacyS7Heading,
      l10n.legalPrivacyS8Heading,
      l10n.legalPrivacyS9Heading,
      l10n.legalPrivacyS10Heading,
    ];
    final bodies = [
      l10n.legalPrivacyS1Body,
      l10n.legalPrivacyS2Body,
      l10n.legalPrivacyS3Body,
      l10n.legalPrivacyS4Body,
      l10n.legalPrivacyS5Body,
      l10n.legalPrivacyS6Body,
      l10n.legalPrivacyS7Body,
      l10n.legalPrivacyS8Body,
      l10n.legalPrivacyS9Body,
      l10n.legalPrivacyS10Body,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.legalPrivacyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.legalPrivacyLastUpdated, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.legalPrivacyDraftNotice)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < _sectionCount; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headings[i], style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(bodies[i]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
