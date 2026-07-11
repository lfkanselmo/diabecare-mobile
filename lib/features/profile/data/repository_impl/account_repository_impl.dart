import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../auth/data/local/secure_auth_storage.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/active_session.dart';
import '../../domain/entities/device_api_key.dart';
import '../../domain/repositories/account_repository.dart';
import '../remote/account_api_client.dart';
import '../remote/device_api_key_api_client.dart';
import '../remote/session_api_client.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required AccountApiClient accountApiClient,
    required DeviceApiKeyApiClient deviceApiKeyApiClient,
    required SessionApiClient sessionApiClient,
    required AuthRepository authRepository,
    required SecureAuthStorage secureAuthStorage,
  }) : _accountApiClient = accountApiClient,
       _deviceApiKeyApiClient = deviceApiKeyApiClient,
       _sessionApiClient = sessionApiClient,
       _authRepository = authRepository,
       _secureAuthStorage = secureAuthStorage;

  final AccountApiClient _accountApiClient;
  final DeviceApiKeyApiClient _deviceApiKeyApiClient;
  final SessionApiClient _sessionApiClient;
  final AuthRepository _authRepository;
  final SecureAuthStorage _secureAuthStorage;

  @override
  Future<List<ActiveSession>> getActiveSessions() async {
    final userId = await _requireUserId();
    final sessions = await _sessionApiClient.getActiveSessions(userId);
    return sessions
        .map(
          (s) => ActiveSession(id: s.id, deviceLabel: s.deviceLabel, lastUsedAt: s.lastUsedAt, createdAt: s.createdAt),
        )
        .toList();
  }

  @override
  Future<void> logoutAllSessions() async {
    final userId = await _requireUserId();
    await _sessionApiClient.logoutAll(userId);
    await _authRepository.clearSession();
  }

  @override
  Future<void> suspendAccount() async {
    final userId = await _requireUserId();
    await _accountApiClient.suspend(userId);
    await _authRepository.clearSession();
  }

  @override
  Future<void> deleteAccount() async {
    final userId = await _requireUserId();
    await _accountApiClient.delete(userId);
    await _authRepository.clearSession();
  }

  @override
  Future<void> exportAndShareData() async {
    final userId = await _requireUserId();
    final bytes = await _accountApiClient.exportData(userId);

    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'diabecare_mis_datos.json'));
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  @override
  Future<GeneratedDeviceApiKey> generateDeviceApiKey(String label) async {
    final patientId = await _requirePatientId();
    final dto = await _deviceApiKeyApiClient.generate(patientId: patientId, label: label);
    return GeneratedDeviceApiKey(id: dto.id, rawKey: dto.rawKey, label: dto.label, createdAt: dto.createdAt);
  }

  @override
  Future<List<DeviceApiKey>> listDeviceApiKeys() async {
    final patientId = await _requirePatientId();
    final keys = await _deviceApiKeyApiClient.list(patientId);
    return keys
        .map(
          (k) => DeviceApiKey(
            id: k.id,
            label: k.label,
            createdAt: k.createdAt,
            lastUsedAt: k.lastUsedAt,
            revoked: k.revoked,
          ),
        )
        .toList();
  }

  @override
  Future<void> revokeDeviceApiKey(String keyId) async {
    final patientId = await _requirePatientId();
    await _deviceApiKeyApiClient.revoke(patientId: patientId, keyId: keyId);
  }

  Future<String> _requireUserId() async {
    final userId = await _secureAuthStorage.getUserId();
    if (userId == null) {
      throw StateError('No hay una sesión activa');
    }
    return userId;
  }

  Future<String> _requirePatientId() async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }
    return patientId;
  }
}
