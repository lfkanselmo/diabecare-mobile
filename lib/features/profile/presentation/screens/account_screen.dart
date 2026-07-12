import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../../domain/entities/active_session.dart';
import '../../domain/entities/device_api_key.dart';
import '../providers/account_providers.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Future<List<ActiveSession>>? _sessionsFuture;
  Future<List<DeviceApiKey>>? _keysFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshSessions();
    _refreshKeys();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshSessions() {
    setState(() => _sessionsFuture = ref.read(accountRepositoryProvider).getActiveSessions());
  }

  void _refreshKeys() {
    setState(() => _keysFuture = ref.read(accountRepositoryProvider).listDeviceApiKeys());
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(accountRepositoryProvider).exportAndShareData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.accountErrorMessage)));
      }
    }
  }

  Future<void> _logoutAllSessions() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.accountLogoutAllTitle,
      message: l10n.accountLogoutAllMessage,
      confirmLabel: l10n.accountLogoutAllConfirm,
      cancelLabel: l10n.accountCancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(accountRepositoryProvider).logoutAllSessions();
    if (mounted) context.go('/auth/login');
  }

  Future<void> _suspendAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.accountSuspendTitle,
      message: l10n.accountSuspendMessage,
      confirmLabel: l10n.accountSuspendConfirm,
      cancelLabel: l10n.accountCancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(accountRepositoryProvider).suspendAccount();
    if (mounted) context.go('/auth/login');
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.accountDeleteTitle,
      message: l10n.accountDeleteMessage,
      confirmLabel: l10n.accountDeleteConfirm,
      cancelLabel: l10n.accountCancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(accountRepositoryProvider).deleteAccount();
    if (mounted) context.go('/auth/login');
  }

  Future<void> _generateKey() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountGenerateKeyTitle),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: l10n.accountKeyLabel)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.accountCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.accountGenerateKeyConfirm),
          ),
        ],
      ),
    );
    if (label == null || label.isEmpty || !mounted) return;

    try {
      final generated = await ref.read(accountRepositoryProvider).generateDeviceApiKey(label);
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.accountKeyGeneratedTitle),
            content: SelectableText(generated.rawKey),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.accountClose))],
          ),
        );
      }
      _refreshKeys();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.accountErrorMessage)));
      }
    }
  }

  Future<void> _revokeKey(DeviceApiKey key) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.accountRevokeKeyTitle,
      message: l10n.accountRevokeKeyMessage(key.label),
      confirmLabel: l10n.accountRevokeKeyConfirm,
      cancelLabel: l10n.accountCancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(accountRepositoryProvider).revokeDeviceApiKey(key.id);
    _refreshKeys();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(l10n.localeName).add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l10n.accountTabAccount), Tab(text: l10n.accountTabDevices)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OutlinedButton(onPressed: _exportData, child: Text(l10n.accountExportData)),
                const SizedBox(height: 24),
                Text(l10n.accountSessionsTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                FutureBuilder<List<ActiveSession>>(
                  future: _sessionsFuture,
                  builder: (context, snapshot) {
                    final sessions = snapshot.data;
                    if (sessions == null) return const Center(child: CircularProgressIndicator());
                    return Column(
                      children: [
                        for (final session in sessions)
                          ListTile(
                            title: Text(session.deviceLabel),
                            subtitle: Text(dateFormat.format(session.lastUsedAt)),
                          ),
                      ],
                    );
                  },
                ),
                OutlinedButton(onPressed: _logoutAllSessions, child: Text(l10n.accountLogoutAllTitle)),
                const SizedBox(height: 32),
                Text(l10n.accountDangerZone, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                AppPrimaryButton(label: l10n.accountSuspendTitle, onPressed: _suspendAccount),
                const SizedBox(height: 8),
                AppPrimaryButton(label: l10n.accountDeleteTitle, onPressed: _deleteAccount),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPrimaryButton(label: l10n.accountGenerateKeyTitle, onPressed: _generateKey),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<DeviceApiKey>>(
                      future: _keysFuture,
                      builder: (context, snapshot) {
                        final keys = snapshot.data;
                        if (keys == null) return const Center(child: CircularProgressIndicator());
                        if (keys.isEmpty) return Center(child: Text(l10n.accountNoKeys));
                        return ListView.builder(
                          itemCount: keys.length,
                          itemBuilder: (context, index) {
                            final key = keys[index];
                            return Card(
                              child: ListTile(
                                title: Text(key.label),
                                subtitle: Text(
                                  key.revoked ? l10n.accountKeyRevoked : dateFormat.format(key.createdAt),
                                ),
                                trailing: key.revoked
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: l10n.accountRevokeKeyTitle,
                                        onPressed: () => _revokeKey(key),
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
