import 'package:primer_app/features/documentos/domain/documento_analizado.dart';

/// Lo que la aplicación necesita saber de los documentos analizados.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo.
abstract interface class DocumentosRepository {
  Future<List<DocumentoAnalizado>> obtenerTodos();

  Future<DocumentoAnalizado?> obtenerPorId(String id);
}
