import 'package:primer_app/core/comparaciones.dart';
import 'package:primer_app/core/json.dart';
import 'package:primer_app/features/documentos/domain/texto_extraido.dart';

/// En qué punto de su vida está un documento analizado.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoDocumento {
  const EstadoDocumento();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoDocumento.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'cargado' => Cargado(leerFecha(json, 'cargadoEn')),
      'analizando' => Analizando(leerTexto(json, 'pasos')),
      'analizado' => Analizado(
        TextoExtraido.fromJson(leerMapa(json, 'texto')),
        leerTextos(json, 'alertas'),
      ),
      'con_error' => ConError(leerTexto(json, 'mensaje')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson.
  Map<String, dynamic> toJson() => switch (this) {
    Cargado(:final cargadoEn) => {
      'tipo': 'cargado',
      'cargadoEn': cargadoEn.toIso8601String(),
    },
    Analizando(:final pasos) => {'tipo': 'analizando', 'pasos': pasos},
    Analizado(:final texto, :final alertas) => {
      'tipo': 'analizado',
      'texto': texto.toJson(),
      'alertas': alertas,
    },
    ConError(:final mensaje) => {'tipo': 'con_error', 'mensaje': mensaje},
  };

  /// Regla de negocio: quién puede volver a procesar el documento.
  bool get sePuedeReanalizar => switch (this) {
    ConError() || Analizado() => true,
    Cargado() || Analizando() => false,
  };

  /// Texto para la pantalla.
  String get etiqueta => switch (this) {
    Cargado() => 'Cargado',
    Analizando(:final pasos) => 'Analizando: $pasos',
    Analizado() => 'Analizado',
    ConError(:final mensaje) => 'Error: $mensaje',
  };
}

final class Cargado extends EstadoDocumento {
  const Cargado(this.cargadoEn);

  final DateTime cargadoEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cargado && other.cargadoEn == cargadoEn;

  @override
  int get hashCode => Object.hash(runtimeType, cargadoEn);

  @override
  String toString() => 'Cargado($cargadoEn)';
}

final class Analizando extends EstadoDocumento {
  const Analizando(this.pasos);

  final String pasos;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Analizando && other.pasos == pasos;

  @override
  int get hashCode => Object.hash(runtimeType, pasos);

  @override
  String toString() => 'Analizando($pasos)';
}

final class Analizado extends EstadoDocumento {
  const Analizado(this.texto, this.alertas);

  final TextoExtraido texto;
  final List<String> alertas;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Analizado &&
          other.texto == texto &&
          listasIguales(other.alertas, alertas);

  @override
  int get hashCode => Object.hash(runtimeType, texto, Object.hashAll(alertas));

  @override
  String toString() => 'Analizado(${alertas.length} alertas)';
}

final class ConError extends EstadoDocumento {
  const ConError(this.mensaje)
    : assert(mensaje != '', 'reportar error exige mensaje');

  final String mensaje;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ConError && other.mensaje == mensaje;

  @override
  int get hashCode => Object.hash(runtimeType, mensaje);

  @override
  String toString() => 'ConError($mensaje)';
}
