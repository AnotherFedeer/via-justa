import 'package:primer_app/core/json.dart';
import 'package:primer_app/features/documentos/domain/estado_documento.dart';

/// Un documento fotografiado que fue procesado con OCR y analizado con IA.
///
/// Es una **entidad**: tiene identidad propia. Dos documentos con la misma foto
/// son dos documentos distintos si tienen `id` distinto.
class DocumentoAnalizado {
  const DocumentoAnalizado({
    required this.id,
    required this.fotoUrl,
    required this.creadoEn,
    required this.estado,
  });

  factory DocumentoAnalizado.fromJson(Map<String, dynamic> json) =>
      DocumentoAnalizado(
        id: leerTexto(json, 'id'),
        fotoUrl: leerTexto(json, 'fotoUrl'),
        creadoEn: leerFecha(json, 'creadoEn'),
        estado: EstadoDocumento.fromJson(leerMapa(json, 'estado')),
      );

  final String id;
  final String fotoUrl;
  final DateTime creadoEn;
  final EstadoDocumento estado;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fotoUrl': fotoUrl,
    'creadoEn': creadoEn.toUtc().toIso8601String(),
    'estado': estado.toJson(),
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────

  bool get sePuedeReanalizar => estado.sePuedeReanalizar;

  bool get tieneAlertas => switch (estado) {
    Analizado(:final alertas) => alertas.isNotEmpty,
    _ => false,
  };

  bool get confianzaMinima => switch (estado) {
    Analizado(:final texto) => texto.confianza >= 0.7,
    _ => false,
  };

  Duration antiguedad(DateTime ahora) => ahora.difference(creadoEn);

  bool estaVencido(DateTime ahora) =>
      antiguedad(ahora) > const Duration(days: 30);

  // ── Copia ───────────────────────────────────────────────────────────────

  DocumentoAnalizado copyWith({String? fotoUrl, EstadoDocumento? estado}) =>
      DocumentoAnalizado(
        id: id,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        creadoEn: creadoEn,
        estado: estado ?? this.estado,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentoAnalizado &&
          other.id == id &&
          other.fotoUrl == fotoUrl &&
          other.creadoEn == creadoEn &&
          other.estado == estado;

  @override
  int get hashCode => Object.hash(id, fotoUrl, creadoEn, estado);

  @override
  String toString() => 'DocumentoAnalizado($id, $fotoUrl, ${estado.etiqueta})';
}
