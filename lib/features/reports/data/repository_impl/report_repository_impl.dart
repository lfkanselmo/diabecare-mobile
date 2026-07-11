import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../remote/report_api_client.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required ReportApiClient apiClient, required AuthRepository authRepository})
    : _apiClient = apiClient,
      _authRepository = authRepository;

  final ReportApiClient _apiClient;
  final AuthRepository _authRepository;

  @override
  Future<void> generateAndShare({required DateTime from, required DateTime to}) async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }

    final bytes = await _apiClient.generateMedicalReport(patientId: patientId, from: from, to: to);

    final dir = await getTemporaryDirectory();
    final filename = 'DiabeCare_Reporte_${_ddMMyyyy(from)}_${_ddMMyyyy(to)}.pdf';
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  String _ddMMyyyy(DateTime date) {
    String pad2(int n) => n.toString().padLeft(2, '0');
    return '${pad2(date.day)}${pad2(date.month)}${date.year}';
  }
}
