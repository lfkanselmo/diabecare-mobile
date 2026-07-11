import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/repository_impl/alerts_repository_impl.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alerts_repository.dart';

part 'alerts_provider.g.dart';

@Riverpod(keepAlive: true)
AlertsRepository alertsRepository(Ref ref) => AlertsRepositoryImpl(
  dio: ref.watch(apiDioProvider),
  authRepository: ref.watch(authRepositoryProvider),
);

/// Sin polling — se refresca al entrar al dashboard (`build`) y a mano tras
/// cualquier acción que pueda generar una alerta nueva (`refresh()`), igual
/// que el patrón "refrescar tras acción mutante" de la web (nunca hubo
/// polling ahí tampoco).
@Riverpod(keepAlive: true)
class Alerts extends _$Alerts {
  @override
  Future<List<Alert>> build() => ref.watch(alertsRepositoryProvider).getAlerts();

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(alertsRepositoryProvider).getAlerts());
  }
}
