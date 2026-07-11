import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/remote/caregiver_api_client.dart';
import '../../data/repository_impl/caregiver_repository_impl.dart';
import '../../domain/repositories/caregiver_repository.dart';

part 'caregiver_providers.g.dart';

@Riverpod(keepAlive: true)
CaregiverApiClient caregiverApiClient(Ref ref) => CaregiverApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
CaregiverRepository caregiverRepository(Ref ref) => CaregiverRepositoryImpl(
  apiClient: ref.watch(caregiverApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
);
