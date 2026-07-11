import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/remote/report_api_client.dart';
import '../../data/repository_impl/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';

part 'report_providers.g.dart';

@Riverpod(keepAlive: true)
ReportApiClient reportApiClient(Ref ref) => ReportApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
ReportRepository reportRepository(Ref ref) =>
    ReportRepositoryImpl(apiClient: ref.watch(reportApiClientProvider), authRepository: ref.watch(authRepositoryProvider));
