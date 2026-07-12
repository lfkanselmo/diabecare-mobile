import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/caregivers/presentation/screens/caregiver_patient_view_screen.dart';
import '../../features/caregivers/presentation/screens/caregivers_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/glucose/presentation/screens/agp_chart_screen.dart';
import '../../features/glucose/presentation/screens/glucose_history_screen.dart';
import '../../features/glucose/presentation/screens/glucose_register_screen.dart';
import '../../features/legal/presentation/screens/privacy_policy_screen.dart';
import '../../features/medications/presentation/screens/insulin_calculator_screen.dart';
import '../../features/medications/presentation/screens/insulin_profile_screen.dart';
import '../../features/medications/presentation/screens/medication_list_screen.dart';
import '../../features/medications/presentation/screens/medication_register_screen.dart';
import '../../features/menstrual_cycle/presentation/screens/cycle_day_entry_screen.dart';
import '../../features/menstrual_cycle/presentation/screens/menstrual_cycle_screen.dart';
import '../../features/nutrition/presentation/screens/meal_history_screen.dart';
import '../../features/nutrition/presentation/screens/meal_register_screen.dart';
import '../../features/profile/presentation/screens/account_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reports/presentation/screens/report_screen.dart';
import '../../features/vitals/presentation/screens/exercise_register_screen.dart';
import '../../features/vitals/presentation/screens/vital_sign_register_screen.dart';
import '../../features/vitals/presentation/screens/vitals_screen.dart';
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
      GoRoute(path: '/nutrition/log', builder: (context, state) => const MealRegisterScreen()),
      GoRoute(path: '/nutrition/history', builder: (context, state) => const MealHistoryScreen()),
      GoRoute(path: '/vitals', builder: (context, state) => const VitalsScreen()),
      GoRoute(path: '/vitals/register', builder: (context, state) => const VitalSignRegisterScreen()),
      GoRoute(path: '/exercise/register', builder: (context, state) => const ExerciseRegisterScreen()),
      GoRoute(path: '/medications', builder: (context, state) => const MedicationListScreen()),
      GoRoute(path: '/medications/register', builder: (context, state) => const MedicationRegisterScreen()),
      GoRoute(
        path: '/medications/insulin-profile',
        builder: (context, state) => const InsulinProfileScreen(),
      ),
      GoRoute(
        path: '/medications/insulin-calculator',
        builder: (context, state) => const InsulinCalculatorScreen(),
      ),
      GoRoute(path: '/cycle', builder: (context, state) => const MenstrualCycleScreen()),
      GoRoute(path: '/cycle/log', builder: (context, state) => const CycleDayEntryScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const ReportScreen()),
      GoRoute(path: '/caregivers', builder: (context, state) => const CaregiversScreen()),
      GoRoute(
        path: '/caregivers/patients/:patientId',
        builder: (context, state) =>
            CaregiverPatientViewScreen(patientId: state.pathParameters['patientId']!),
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/account', builder: (context, state) => const AccountScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => ResetPasswordScreen(token: state.uri.queryParameters['token']),
      ),
      GoRoute(path: '/legal/privacy', builder: (context, state) => const PrivacyPolicyScreen()),
    ],
  );
}

/// Reproduce `auth.guard.ts`: token válido → pasa; sin token pero con
/// refresh token → intenta refresh proactivo; si no → redirige a login.
/// `/admin` además reproduce `admin.guard.ts`: sin rol ADMIN, redirige al
/// dashboard en vez de dejar pasar (el backend igual lo exige aparte).
/// `/legal/privacy` es pública a propósito, igual que en la web (`app.routes.ts`
/// la deja fuera del `authGuard`) — el registro enlaza ahí antes de que exista sesión.
Future<String?> _redirect(AuthRepository authRepository, GoRouterState state) async {
  if (state.matchedLocation.startsWith('/legal')) return null;

  final goingToAuth = state.matchedLocation.startsWith('/auth');

  if (await authRepository.isAuthenticated()) {
    if (state.matchedLocation == '/admin') {
      final session = await authRepository.loadSession();
      if (session?.isAdmin != true) return '/';
    }
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
