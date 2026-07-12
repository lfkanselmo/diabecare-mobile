import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/user_role.dart';
import '../providers/admin_providers.dart';

/// Solo alcanzable si `session.role == 'ADMIN'` (ver `app_router.dart`) —
/// el backend igual lo exige con `@PreAuthorize`, esto es solo el cliente.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  static const _pageSize = 20;

  int _page = 0;
  String? _currentUserId;
  Future<AdminUserPage>? _pageFuture;

  @override
  void initState() {
    super.initState();
    ref.read(secureAuthStorageProvider).getUserId().then((id) {
      if (mounted) setState(() => _currentUserId = id);
    });
    _load();
  }

  void _load() {
    setState(() => _pageFuture = ref.read(adminRepositoryProvider).getUsers(page: _page, size: _pageSize));
  }

  Future<void> _toggleRole(AdminUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final newRole = user.role == UserRole.admin ? UserRole.patient : UserRole.admin;

    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.adminChangeRoleTitle,
      message: l10n.adminChangeRoleMessage(user.email, newRole.wireValue),
      confirmLabel: l10n.adminChangeRoleConfirm,
      cancelLabel: l10n.adminCancel,
    );
    if (!confirmed) return;

    try {
      await ref.read(adminRepositoryProvider).changeUserRole(userId: user.id, role: newRole);
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminErrorMessage)));
      }
    }
  }

  Future<void> _reloadConfig() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(adminRepositoryProvider).reloadSystemConfig();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminConfigReloaded)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminErrorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(l10n.localeName);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.adminReloadConfig,
            onPressed: _reloadConfig,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<AdminUserPage>(
          future: _pageFuture,
          builder: (context, snapshot) {
            final page = snapshot.data;
            if (page == null) return const Center(child: CircularProgressIndicator());

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: page.content.length,
                    itemBuilder: (context, index) {
                      final user = page.content[index];
                      final isSelf = user.id == _currentUserId;
                      return ListTile(
                        title: Text(user.email),
                        subtitle: Text(
                          '${user.role.wireValue} · ${dateFormat.format(user.createdAt)}'
                          '${user.suspendedAt != null ? ' · ${l10n.adminSuspended}' : ''}'
                          '${user.deletedAt != null ? ' · ${l10n.adminDeleted}' : ''}',
                        ),
                        trailing: isSelf
                            ? Text(l10n.adminThatsYou, style: Theme.of(context).textTheme.bodySmall)
                            : TextButton(
                                onPressed: () => _toggleRole(user),
                                child: Text(
                                  user.role == UserRole.admin ? l10n.adminDemote : l10n.adminPromote,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        tooltip: l10n.adminPreviousPage,
                        onPressed: _page > 0
                            ? () {
                                setState(() => _page -= 1);
                                _load();
                              }
                            : null,
                      ),
                      Text(l10n.adminPageIndicator(_page + 1, page.totalPages == 0 ? 1 : page.totalPages)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        tooltip: l10n.adminNextPage,
                        onPressed: _page + 1 < page.totalPages
                            ? () {
                                setState(() => _page += 1);
                                _load();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
