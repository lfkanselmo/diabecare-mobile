import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diabecare_mobile/main.dart';

void main() {
  testWidgets('la app arranca y muestra la pantalla placeholder de Fase 0', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DiabeCareApp()));

    expect(find.textContaining('DiabeCare Mobile'), findsOneWidget);
  });
}
