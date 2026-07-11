/// Sin persistencia local — el PDF se genera server-side y se comparte de
/// inmediato (`share_plus`), no se guarda como un dato de dominio propio.
abstract interface class ReportRepository {
  Future<void> generateAndShare({required DateTime from, required DateTime to});
}
