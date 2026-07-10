import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'biometric_lock_service.dart';

part 'security_providers.g.dart';

@Riverpod(keepAlive: true)
BiometricLockService biometricLockService(Ref ref) => BiometricLockService();
