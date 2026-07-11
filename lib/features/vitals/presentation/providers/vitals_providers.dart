import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/local/exercise_log_dao.dart';
import '../../data/local/vital_sign_dao.dart';
import '../../data/remote/exercise_log_api_client.dart';
import '../../data/remote/vital_sign_api_client.dart';
import '../../data/repository_impl/exercise_log_repository_impl.dart';
import '../../data/repository_impl/vital_sign_repository_impl.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/exercise_log_repository.dart';
import '../../domain/repositories/vital_sign_repository.dart';

part 'vitals_providers.g.dart';

@Riverpod(keepAlive: true)
VitalSignDao vitalSignDao(Ref ref) => VitalSignDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
VitalSignApiClient vitalSignApiClient(Ref ref) => VitalSignApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
VitalSignRepository vitalSignRepository(Ref ref) => VitalSignRepositoryImpl(
  dao: ref.watch(vitalSignDaoProvider),
  apiClient: ref.watch(vitalSignApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  database: ref.watch(appDatabaseProvider),
);

@Riverpod(keepAlive: true)
ExerciseLogDao exerciseLogDao(Ref ref) => ExerciseLogDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
ExerciseLogApiClient exerciseLogApiClient(Ref ref) => ExerciseLogApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
ExerciseLogRepository exerciseLogRepository(Ref ref) => ExerciseLogRepositoryImpl(
  dao: ref.watch(exerciseLogDaoProvider),
  apiClient: ref.watch(exerciseLogApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  database: ref.watch(appDatabaseProvider),
);

@riverpod
Stream<List<VitalSign>> vitalsByRange(Ref ref, {required DateTime from, required DateTime to}) {
  return ref.watch(vitalSignRepositoryProvider).watchVitals(from: from, to: to);
}

@riverpod
Stream<List<ExerciseLog>> exerciseLogsByRange(Ref ref, {required DateTime from, required DateTime to}) {
  return ref.watch(exerciseLogRepositoryProvider).watchLogs(from: from, to: to);
}
