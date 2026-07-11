import '../entities/alert.dart';

/// Sin caché — red-first, igual que `alert.service.ts` en la web (las
/// alertas nunca se sirven desde una copia local vieja).
abstract interface class AlertsRepository {
  Future<List<Alert>> getAlerts();
}
