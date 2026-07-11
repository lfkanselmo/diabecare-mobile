/// Debe coincidir con `Severity` (enum) del backend.
enum AlertSeverity {
  success('SUCCESS'),
  info('INFO'),
  warning('WARNING'),
  danger('DANGER');

  const AlertSeverity(this.wireValue);

  final String wireValue;

  static AlertSeverity fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}

/// Mirror de `AlertResponse` del backend. `type` se trata como string
/// opaco (9 valores hoy, ver `Alert.AlertType` del backend) — la propia web
/// nunca lo usa para lógica de UI, solo `severity` decide color/ícono.
class Alert {
  const Alert({required this.type, required this.severity, required this.title, required this.message});

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
    type: json['type'] as String,
    severity: AlertSeverity.fromWire(json['severity'] as String),
    title: json['title'] as String,
    message: json['message'] as String,
  );

  final String type;
  final AlertSeverity severity;
  final String title;
  final String message;
}
