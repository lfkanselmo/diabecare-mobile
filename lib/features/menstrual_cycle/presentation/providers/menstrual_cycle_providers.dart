import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/remote/menstrual_cycle_api_client.dart';
import '../../data/repository_impl/menstrual_cycle_repository_impl.dart';
import '../../domain/repositories/menstrual_cycle_repository.dart';

part 'menstrual_cycle_providers.g.dart';

@Riverpod(keepAlive: true)
MenstrualCycleApiClient menstrualCycleApiClient(Ref ref) => MenstrualCycleApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
MenstrualCycleRepository menstrualCycleRepository(Ref ref) => MenstrualCycleRepositoryImpl(
  apiClient: ref.watch(menstrualCycleApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
);
