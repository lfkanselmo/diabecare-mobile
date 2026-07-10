import '../../features/auth/domain/repositories/auth_repository.dart';

/// Evita refrescos concurrentes duplicados — mismo problema que
/// `TokenRefreshCoordinator` resuelve en `diabecare-web`. Si ya hay un
/// refresh en curso, los llamadores concurrentes esperan el mismo `Future`
/// en vez de disparar uno nuevo cada uno (un `Future` de Dart ya soporta
/// múltiples listeners, así que no hace falta un `BehaviorSubject`).
class RefreshCoordinator {
  RefreshCoordinator(this._authRepository);

  final AuthRepository _authRepository;
  Future<String>? _inFlight;

  Future<String> refreshAccessToken() {
    return _inFlight ??= _doRefresh();
  }

  Future<String> _doRefresh() async {
    try {
      return await _authRepository.refreshAccessToken();
    } finally {
      _inFlight = null;
    }
  }
}
