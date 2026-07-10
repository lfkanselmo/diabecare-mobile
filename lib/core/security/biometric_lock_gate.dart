import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'security_providers.dart';

/// Envuelve el árbol autenticado de la app: si el toggle de bloqueo
/// biométrico está activo, exige autenticación cada vez que la app vuelve
/// de segundo plano.
class BiometricLockGate extends ConsumerStatefulWidget {
  const BiometricLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends ConsumerState<BiometricLockGate> with WidgetsBindingObserver {
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeLock();
    }
  }

  Future<void> _maybeLock() async {
    final service = ref.read(biometricLockServiceProvider);
    if (await service.isEnabled() && mounted) {
      setState(() => _locked = true);
    }
  }

  Future<void> _unlock() async {
    final service = ref.read(biometricLockServiceProvider);
    final success = await service.authenticate(reason: 'Desbloquea DiabeCare para continuar');
    if (success && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_locked) return widget.child;

    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: _unlock, child: const Text('Desbloquear')),
      ),
    );
  }
}
