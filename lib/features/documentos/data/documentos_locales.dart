import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:primer_app/core/json.dart';
import 'package:primer_app/features/documentos/domain/documento_analizado.dart';
import 'package:primer_app/features/documentos/domain/documentos_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class DocumentosLocales implements DocumentosRepository {
  DocumentosLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/documentos.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  List<DocumentoAnalizado>? _cache;

  @override
  Future<List<DocumentoAnalizado>> obtenerTodos() async {
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
        .map((e) => DocumentoAnalizado.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<DocumentoAnalizado?> obtenerPorId(String id) async {
    for (final doc in await obtenerTodos()) {
      if (doc.id == id) return doc;
    }
    return null;
  }
}
