import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/security/security_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Hub de navegación — perfil del paciente, bloqueo biométrico (el toggle
/// diferido desde Fase 0, ver `BiometricLockService`), y accesos a
/// cuidadores/reportes/gestión de cuenta.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final service = ref.read(biometricLockServiceProvider);
    final available = await service.isAvailable();
    final enabled = await service.isEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    await ref.read(biometricLockServiceProvider).setEnabled(value);
    setState(() => _biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            if (session?.patient != null)
              ListTile(
                title: Text(session!.patient!.fullName),
                subtitle: Text(session.patient!.diabetesType.wireValue),
              ),
            const Divider(),
            if (_biometricAvailable)
              SwitchListTile(
                title: Text(l10n.profileBiometricLock),
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
              ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: Text(l10n.profileInsulinProfile),
              onTap: () => context.push('/medications/insulin-profile'),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: Text(l10n.profileCaregivers),
              onTap: () => context.push('/caregivers'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(l10n.profileReports),
              onTap: () => context.push('/reports'),
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: Text(l10n.profileAccount),
              onTap: () => context.push('/account'),
            ),
            if (session?.isAdmin ?? false)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(l10n.profileAdmin),
                onTap: () => context.push('/admin'),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.profileLogout),
              onTap: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}
