import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/glucose/presentation/screens/agp_chart_screen.dart';
import '../../features/glucose/presentation/screens/glucose_history_screen.dart';
import '../../features/glucose/presentation/screens/glucose_register_screen.dart';
import '../network/network_providers.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: ref.watch(sessionExpiredProvider),
    redirect: (context, state) => _redirect(authRepository, state),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/glucose/register', builder: (context, state) => const GlucoseRegisterScreen()),
      GoRoute(path: '/glucose/history', builder: (context, state) => const GlucoseHistoryScreen()),
      GoRoute(path: '/glucose/agp', builder: (context, state) => const AgpChartScreen()),
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
