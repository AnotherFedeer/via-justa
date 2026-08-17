import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:primer_app/core/json.dart';
import 'package:primer_app/features/reportes/domain/estado_reporte.dart';
import 'package:primer_app/features/reportes/domain/monto.dart';
import 'package:primer_app/features/reportes/domain/reporte_precio.dart';

ReportePrecio ejemplo({EstadoReporte? estado, List<String>? fotos}) =>
    ReportePrecio(
      id: 'rp-001',
      categoria: 'transporte',
      monto: const Monto(cantidad: 4500, moneda: 'COP'),
      ubicacion: 'Valledupar, Barrio Centro',
      creadoEn: DateTime.utc(2026, 8, 10, 19, 5),
      estado: estado ?? const Borrador(),
      fotos: fotos ?? const <String>[],
    );

void main() {
  group('serialización', () {
    test('un reporte sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Enviado(DateTime.utc(2026, 8, 10, 19, 6, 30)),
        fotos: const ['https://ejemplo.co/f/1.jpg'],
      );

      final texto = jsonEncode(original.toJson());
      final vuelta = ReportePrecio.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(vuelta, equals(original));
    });

    test('un reporte sin la clave fotos se lee con la lista vacía', () {
      final json = ejemplo().toJson()..remove('fotos');
      expect(ReportePrecio.fromJson(json).fotos, isEmpty);
    });

    test('un reporte sin categoría dice QUÉ campo falló', () {
      final json = ejemplo().toJson()..remove('categoria');

      expect(
        () => ReportePrecio.fromJson(json),
        throwsA(
          isA<CampoInvalido>().having((e) => e.campo, 'campo', 'categoria'),
        ),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['creadoEn'] = '10 de agosto';
      expect(() => ReportePrecio.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['creadoEn'], '2026-08-10T19:05:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos reportes con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos reportes con los mismos datos comparten hashCode', () {
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos reportes con fotos distintas NO son iguales', () {
      expect(
        ejemplo(fotos: const ['a']),
        isNot(equals(ejemplo(fotos: const ['b']))),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(categoria: 'mercado');

      expect(copia.categoria, 'mercado');
      expect(copia.id, original.id);
      expect(copia.creadoEn, original.creadoEn);
    });
  });

  group('reglas de negocio', () {
    test('un reporte verificado no se puede editar', () {
      expect(
        ejemplo(estado: const Verificado('analista-1', 4200)).sePuedeEditar,
        isFalse,
      );
    });

    test('un reporte rechazado sí se puede editar', () {
      expect(
        ejemplo(estado: const Rechazado('monto sospechoso')).sePuedeEditar,
        isTrue,
      );
    });

    test('un reporte de hace 40 días está vencido', () {
      final ahora = DateTime.utc(2026, 9, 20);
      expect(ejemplo().estaVencido(ahora), isTrue);
    });

    test('la etiqueta de un rechazo incluye el motivo', () {
      expect(
        const Rechazado('faltan fotos').etiqueta,
        contains('faltan fotos'),
      );
    });
  });
}
