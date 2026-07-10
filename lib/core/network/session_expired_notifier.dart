import 'package:flutter/foundation.dart';

/// Puente entre el interceptor de red (que detecta una sesión terminada en
/// medio de una request cualquiera) y el router (que debe redirigir a
/// login). go_router escucha esto vía `refreshListenable`.
class SessionExpiredNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
