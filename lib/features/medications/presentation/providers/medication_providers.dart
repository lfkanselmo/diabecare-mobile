import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/local/medication_dao.dart';
import '../../data/remote/medication_api_client.dart';
import '../../data/repository_impl/medication_repository_impl.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';

part 'medication_providers.g.dart';

@Riverpod(keepAlive: true)
MedicationDao medicationDao(Ref ref) => MedicationDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
MedicationApiClient medicationApiClient(Ref ref) => MedicationApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
MedicationRepository medicationRepository(Ref ref) => MedicationRepositoryImpl(
  dao: ref.watch(medicationDaoProvider),
  apiClient: ref.watch(medicationApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  database: ref.watch(appDatabaseProvider),
);

@riverpod
Stream<List<Medication>> activeMedications(Ref ref) {
  return ref.watch(medicationRepositoryProvider).watchActive();
}
