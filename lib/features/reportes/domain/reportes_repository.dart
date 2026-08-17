import 'package:primer_app/features/reportes/domain/reporte_precio.dart';

/// Lo que la aplicación necesita saber de los reportes de precio.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo.
abstract interface class ReportesRepository {
  Future<List<ReportePrecio>> obtenerTodos();

  Future<ReportePrecio?> obtenerPorId(String id);
}
