import 'package:primer_app/core/json.dart';

/// En qué punto de su vida está un reporte de precio.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoReporte {
  const EstadoReporte();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoReporte.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'borrador' => const Borrador(),
      'enviado' => Enviado(leerFecha(json, 'enviadoEn')),
      'verificado' => Verificado(
        leerTexto(json, 'verificadoPor'),
        leerDecimal(json, 'promedioZona'),
      ),
      'rechazado' => Rechazado(leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    Borrador() => {'tipo': 'borrador'},
    Enviado(:final enviadoEn) => {
      'tipo': 'enviado',
      'enviadoEn': enviadoEn.toIso8601String(),
    },
    Verificado(:final verificadoPor, :final promedioZona) => {
      'tipo': 'verificado',
      'verificadoPor': verificadoPor,
      'promedioZona': promedioZona,
    },
    Rechazado(:final motivo) => {'tipo': 'rechazado', 'motivo': motivo},
  };

  /// Regla de negocio: quién puede tocar el reporte.
  bool get sePuedeEditar => switch (this) {
    Borrador() || Enviado() || Rechazado() => true,
    Verificado() => false,
  };

  /// Texto para la pantalla.
  String get etiqueta => switch (this) {
    Borrador() => 'Borrador',
    Enviado() => 'Enviado',
    Verificado(:final verificadoPor) => 'Verificado por $verificadoPor',
    Rechazado(:final motivo) => 'Rechazado: $motivo',
  };
}

final class Borrador extends EstadoReporte {
  const Borrador();

  @override
  bool operator ==(Object other) => other is Borrador;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Borrador()';
}

final class Enviado extends EstadoReporte {
  const Enviado(this.enviadoEn);

  final DateTime enviadoEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Enviado && other.enviadoEn == enviadoEn;

  @override
  int get hashCode => Object.hash(runtimeType, enviadoEn);

  @override
  String toString() => 'Enviado($enviadoEn)';
}

final class Verificado extends EstadoReporte {
  const Verificado(this.verificadoPor, this.promedioZona);

  final String verificadoPor;
  final double promedioZona;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Verificado &&
          other.verificadoPor == verificadoPor &&
          other.promedioZona == promedioZona;

  @override
  int get hashCode => Object.hash(runtimeType, verificadoPor, promedioZona);

  @override
  String toString() => 'Verificado($verificadoPor, $promedioZona)';
}

final class Rechazado extends EstadoReporte {
  const Rechazado(this.motivo) : assert(motivo != '', 'rechazar exige motivo');

  final String motivo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Rechazado && other.motivo == motivo;

  @override
  int get hashCode => Object.hash(runtimeType, motivo);

  @override
  String toString() => 'Rechazado($motivo)';
}
