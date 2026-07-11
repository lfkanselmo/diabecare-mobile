import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/glucose/presentation/providers/glucose_providers.dart';
import '../../features/medications/presentation/providers/medication_providers.dart';
import '../../features/nutrition/presentation/providers/nutrition_providers.dart';
import '../../features/vitals/presentation/providers/vitals_providers.dart';
import 'sync_coordinator.dart';
import 'sync_service.dart';
import 'syncable_repository.dart';

part 'sync_providers.g.dart';

/// Cada dominio offline-first (glucosa es el primero, Fase 1; comidas,
/// vitales, ejercicio y medicamentos se agregan en Fase 2) se registra acá —
/// el resto del motor no necesita cambios.
@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  return SyncService(
    repositories: [
      ref.watch(glucoseRepositoryProvider) as SyncableRepository<dynamic>,
      ref.watch(mealRepositoryProvider) as SyncableRepository<dynamic>,
      ref.watch(vitalSignRepositoryProvider) as SyncableRepository<dynamic>,
      ref.watch(exerciseLogRepositoryProvider) as SyncableRepository<dynamic>,
      ref.watch(medicationRepositoryProvider) as SyncableRepository<dynamic>,
    ],
  );
}

@Riverpod(keepAlive: true)
SyncCoordinator syncCoordinator(Ref ref) {
  final coordinator = SyncCoordinator(
    syncService: ref.watch(syncServiceProvider),
    pullers: [
      () => ref.watch(glucoseRepositoryProvider).pullChanges(),
      () => ref.watch(mealRepositoryProvider).pullChanges(),
      () => ref.watch(vitalSignRepositoryProvider).pullChanges(),
      () => ref.watch(exerciseLogRepositoryProvider).pullChanges(),
      () => ref.watch(medicationRepositoryProvider).pullChanges(),
    ],
  );
  coordinator.startWatchingConnectivity();
  ref.onDispose(coordinator.dispose);
  return coordinator;
}
