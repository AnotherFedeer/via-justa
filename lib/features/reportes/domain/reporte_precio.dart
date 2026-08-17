import 'package:primer_app/core/comparaciones.dart';
import 'package:primer_app/core/json.dart';
import 'package:primer_app/features/reportes/domain/estado_reporte.dart';
import 'package:primer_app/features/reportes/domain/monto.dart';

/// Un reporte de precio ciudadano.
///
/// Es una **entidad**: tiene identidad propia. Dos reportes con el mismo monto
/// son dos reportes distintos si tienen `id` distinto.
class ReportePrecio {
  const ReportePrecio({
    required this.id,
    required this.categoria,
    required this.monto,
    required this.ubicacion,
    required this.creadoEn,
    required this.estado,
    this.fotos = const <String>[],
  });

  factory ReportePrecio.fromJson(Map<String, dynamic> json) => ReportePrecio(
    id: leerTexto(json, 'id'),
    categoria: leerTexto(json, 'categoria'),
    monto: Monto.fromJson(leerMapa(json, 'monto')),
    ubicacion: leerTexto(json, 'ubicacion'),
    creadoEn: leerFecha(json, 'creadoEn'),
    estado: EstadoReporte.fromJson(leerMapa(json, 'estado')),
    fotos: leerTextos(json, 'fotos'),
  );

  final String id;
  final String categoria;
  final Monto monto;
  final String ubicacion;
  final DateTime creadoEn;
  final EstadoReporte estado;
  final List<String> fotos;

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoria': categoria,
    'monto': monto.toJson(),
    'ubicacion': ubicacion,
    'creadoEn': creadoEn.toUtc().toIso8601String(),
    'estado': estado.toJson(),
    'fotos': fotos,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────

  bool get tieneEvidencia => fotos.isNotEmpty;

  bool get sePuedeEditar => estado.sePuedeEditar;

  Duration antiguedad(DateTime ahora) => ahora.difference(creadoEn);

  bool estaVencido(DateTime ahora) =>
      antiguedad(ahora) > const Duration(days: 30);

  // ── Copia ───────────────────────────────────────────────────────────────

  ReportePrecio copyWith({
    String? categoria,
    Monto? monto,
    String? ubicacion,
    EstadoReporte? estado,
    List<String>? fotos,
  }) => ReportePrecio(
    id: id,
    categoria: categoria ?? this.categoria,
    monto: monto ?? this.monto,
    ubicacion: ubicacion ?? this.ubicacion,
    creadoEn: creadoEn,
    estado: estado ?? this.estado,
    fotos: fotos ?? this.fotos,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportePrecio &&
          other.id == id &&
          other.categoria == categoria &&
          other.monto == monto &&
          other.ubicacion == ubicacion &&
          other.creadoEn == creadoEn &&
          other.estado == estado &&
          listasIguales(other.fotos, fotos);

  @override
  int get hashCode => Object.hash(
    id,
    categoria,
    monto,
    ubicacion,
    creadoEn,
    estado,
    Object.hashAll(fotos),
  );

  @override
  String toString() => 'ReportePrecio($id, $categoria, ${estado.etiqueta})';
}
