import 'package:diabecare_mobile/core/network/network_providers.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:diabecare_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('sin sesión guardada, la app redirige a la pantalla de login', (tester) async {
    final authRepository = _FakeAuthRepository();
    when(() => authRepository.isAuthenticated()).thenAnswer((_) async => false);
    when(() => authRepository.getRefreshToken()).thenAnswer((_) async => null);
    when(() => authRepository.loadSession()).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
        child: const DiabeCareApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
