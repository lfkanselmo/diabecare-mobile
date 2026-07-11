import 'package:dio/dio.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alerts_repository.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  AlertsRepositoryImpl({required Dio dio, required AuthRepository authRepository})
    : _dio = dio,
      _authRepository = authRepository;

  final Dio _dio;
  final AuthRepository _authRepository;

  @override
  Future<List<Alert>> getAlerts() async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }
    final response = await _dio.get<List<dynamic>>('/alerts/$patientId');
    return response.data!.map((e) => Alert.fromJson(e as Map<String, dynamic>)).toList();
  }
}
