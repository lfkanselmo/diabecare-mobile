import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/ble/ble_glucose_meter_service.dart';
import '../../data/local/glucose_dao.dart';
import '../../data/remote/glucose_api_client.dart';
import '../../data/repository_impl/glucose_repository_impl.dart';
import '../../domain/entities/glucose_reading.dart';
import '../../domain/entities/glucose_stats.dart';
import '../../domain/repositories/glucose_repository.dart';

part 'glucose_providers.g.dart';

@Riverpod(keepAlive: true)
BleGlucoseMeterService bleGlucoseMeterService(Ref ref) => BleGlucoseMeterService();

@Riverpod(keepAlive: true)
GlucoseDao glucoseDao(Ref ref) => GlucoseDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
GlucoseApiClient glucoseApiClient(Ref ref) => GlucoseApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
GlucoseRepository glucoseRepository(Ref ref) => GlucoseRepositoryImpl(
  dao: ref.watch(glucoseDaoProvider),
  apiClient: ref.watch(glucoseApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  database: ref.watch(appDatabaseProvider),
);

@riverpod
Stream<List<GlucoseReading>> glucoseReadings(Ref ref, {required DateTime from, required DateTime to}) {
  return ref.watch(glucoseRepositoryProvider).watchReadings(from: from, to: to);
}

class _CachedStats {
  _CachedStats(this.stats, this.fetchedAt);

  final GlucoseStats stats;
  final DateTime fetchedAt;
}

/// TTL de 5 min igual que `selectIsStale` de la web, pero cacheado por
/// `(from, to)` además del timestamp — la web solo cachea por tiempo, lo que
/// sirve alterar el rango de fechas mientras el caché sigue "fresco". No se
/// replica ese bug latente acá.
@Riverpod(keepAlive: true)
class GlucoseStatsCache extends _$GlucoseStatsCache {
  final Map<String, _CachedStats> _cache = {};

  static const _ttl = Duration(minutes: 5);

  @override
  void build() {}

  Future<GlucoseStats> getStats({required DateTime from, required DateTime to}) async {
    final key = '${from.toIso8601String()}_${to.toIso8601String()}';
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.fetchedAt) < _ttl) {
      return cached.stats;
    }
    final stats = await ref.read(glucoseRepositoryProvider).getStats(from: from, to: to);
    _cache[key] = _CachedStats(stats, DateTime.now());
    return stats;
  }
}

@riverpod
Future<GlucoseStats> glucoseStats(Ref ref, {required DateTime from, required DateTime to}) {
  return ref.watch(glucoseStatsCacheProvider.notifier).getStats(from: from, to: to);
}

@riverpod
Future<List<AgpBucket>> glucoseAgpProfile(Ref ref, {required DateTime from, required DateTime to}) {
  return ref.watch(glucoseRepositoryProvider).getAgpProfile(from: from, to: to);
}
