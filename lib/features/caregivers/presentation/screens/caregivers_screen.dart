import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../../domain/entities/caregiver_link.dart';
import '../providers/caregiver_providers.dart';

class CaregiversScreen extends ConsumerStatefulWidget {
  const CaregiversScreen({super.key});

  @override
  ConsumerState<CaregiversScreen> createState() => _CaregiversScreenState();
}

class _CaregiversScreenState extends ConsumerState<CaregiversScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Future<List<CaregiverLink>>? _linksFuture;
  Future<List<PatientAccess>>? _patientsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshLinks();
    _refreshPatients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshLinks() {
    setState(() => _linksFuture = ref.read(caregiverRepositoryProvider).getLinks());
  }

  void _refreshPatients() {
    setState(() => _patientsFuture = ref.read(caregiverRepositoryProvider).getMyPatients());
  }

  Future<void> _createInvite() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final invite = await ref.read(caregiverRepositoryProvider).createInvite();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.caregiversInviteTitle),
          content: Text(l10n.caregiversInviteCode(invite.code)),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.caregiversClose))],
        ),
      );
      _refreshLinks();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.caregiversErrorMessage)));
      }
    }
  }

  Future<void> _revokeLink(CaregiverLink link) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.caregiversRevokeTitle,
      message: l10n.caregiversRevokeMessage(link.caregiverName),
      confirmLabel: l10n.caregiversRevokeConfirm,
      cancelLabel: l10n.caregiversCancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(caregiverRepositoryProvider).revokeLink(link.linkId);
    _refreshLinks();
  }

  Future<void> _redeemCode() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.caregiversRedeemTitle),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: l10n.caregiversRedeemHint)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.caregiversCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.caregiversRedeemConfirm),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;

    try {
      final result = await ref.read(caregiverRepositoryProvider).redeem(code);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.caregiversRedeemSuccess(result.patientFullName))));
      }
      _refreshPatients();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.caregiversRedeemError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(l10n.localeName);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.caregiversTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l10n.caregiversTabMine), Tab(text: l10n.caregiversTabPatients)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPrimaryButton(label: l10n.caregiversCreateInvite, onPressed: _createInvite),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<CaregiverLink>>(
                      future: _linksFuture,
                      builder: (context, snapshot) {
                        final links = snapshot.data;
                        if (links == null) return const Center(child: CircularProgressIndicator());
                        if (links.isEmpty) return Center(child: Text(l10n.caregiversNoLinks));
                        return ListView.builder(
                          itemCount: links.length,
                          itemBuilder: (context, index) {
                            final link = links[index];
                            return Card(
                              child: ListTile(
                                title: Text(link.caregiverName),
                                subtitle: Text('${link.caregiverEmail}\n${dateFormat.format(link.linkedAt)}'),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_remove_outlined),
                                  tooltip: l10n.caregiversRevokeTitle,
                                  onPressed: () => _revokeLink(link),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(onPressed: _redeemCode, child: Text(l10n.caregiversRedeemTitle)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<PatientAccess>>(
                      future: _patientsFuture,
                      builder: (context, snapshot) {
                        final patients = snapshot.data;
                        if (patients == null) return const Center(child: CircularProgressIndicator());
                        if (patients.isEmpty) return Center(child: Text(l10n.caregiversNoPatients));
                        return ListView.builder(
                          itemCount: patients.length,
                          itemBuilder: (context, index) {
                            final patient = patients[index];
                            return Card(
                              child: ListTile(
                                title: Text(patient.patientFullName),
                                subtitle: Text(dateFormat.format(patient.linkedAt)),
                                onTap: () => context.push('/caregivers/patients/${patient.patientId}'),
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
