import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../network/network_providers.dart';
import '../security/biometric_lock_gate.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: ref.watch(sessionExpiredProvider),
    redirect: (context, state) => _redirect(authRepository, state),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _HomePlaceholder()),
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => ResetPasswordScreen(token: state.uri.queryParameters['token']),
      ),
    ],
  );
}

/// Reproduce `auth.guard.ts`: token válido → pasa; sin token pero con
/// refresh token → intenta refresh proactivo; si no → redirige a login.
Future<String?> _redirect(AuthRepository authRepository, GoRouterState state) async {
  final goingToAuth = state.matchedLocation.startsWith('/auth');

  if (await authRepository.isAuthenticated()) {
    return goingToAuth ? '/' : null;
  }

  final refreshToken = await authRepository.getRefreshToken();
  if (refreshToken == null) {
    return goingToAuth ? null : '/auth/login';
  }

  try {
    await authRepository.refreshAccessToken();
    return goingToAuth ? '/' : null;
  } catch (_) {
    await authRepository.clearSession();
    return goingToAuth ? null : '/auth/login';
  }
}

class _HomePlaceholder extends ConsumerWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).value;

    return BiometricLockGate(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DiabeCare'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
        ),
        body: Center(
          child: Text(
            session?.patient == null
                ? 'Sesión iniciada\n(Fase 1 — sin pantallas de dominio todavía)'
                : 'Hola, ${session!.patient!.fullName}\n(Fase 1 — sin pantallas de dominio todavía)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
