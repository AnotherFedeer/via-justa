import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:primer_app/core/json.dart';
import 'package:primer_app/features/reportes/domain/reporte_precio.dart';
import 'package:primer_app/features/reportes/domain/reportes_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class ReportesLocales implements ReportesRepository {
  ReportesLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/reportes.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  List<ReportePrecio>? _cache;

  @override
  Future<List<ReportePrecio>> obtenerTodos() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => ReportePrecio.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ReportePrecio?> obtenerPorId(String id) async {
    for (final reporte in await obtenerTodos()) {
      if (reporte.id == id) return reporte;
    }
    return null;
  }
}
