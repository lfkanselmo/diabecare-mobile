class ActiveSession {
  const ActiveSession({required this.id, required this.deviceLabel, required this.lastUsedAt, required this.createdAt});

  final String id;
  final String deviceLabel;
  final DateTime lastUsedAt;
  final DateTime createdAt;
}
