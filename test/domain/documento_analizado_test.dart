import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:primer_app/core/json.dart';
import 'package:primer_app/features/documentos/domain/estado_documento.dart';
import 'package:primer_app/features/documentos/domain/documento_analizado.dart';
import 'package:primer_app/features/documentos/domain/texto_extraido.dart';

DocumentoAnalizado ejemplo({EstadoDocumento? estado}) => DocumentoAnalizado(
  id: 'doc-001',
  fotoUrl: 'https://ejemplo.co/fotos/contrato1.jpg',
  creadoEn: DateTime.utc(2026, 8, 10, 19, 5),
  estado:
      estado ??
      const Analizado(
        TextoExtraido(contenido: 'Contrato de arriendo.', confianza: 0.92),
        ['Depósito excesivo'],
      ),
);

void main() {
  group('serialización', () {
    test('un documento sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Analizado(
          const TextoExtraido(
            contenido: 'Contrato de arriendo.',
            confianza: 0.92,
          ),
          const ['Depósito excesivo', 'Cláusula oculta'],
        ),
      );

      final texto = jsonEncode(original.toJson());
      final vuelta = DocumentoAnalizado.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(vuelta, equals(original));
    });

    test('un documento cargado sin texto ni alertas se lee correctamente', () {
      final json = ejemplo(estado: Cargado(DateTime.utc(2026, 8, 10, 19, 5)))
          .toJson();
      final doc = DocumentoAnalizado.fromJson(json);
      expect(doc.estado, isA<Cargado>());
    });

    test('un documento sin id dice QUÉ campo falló', () {
      final json = ejemplo().toJson()..remove('id');

      expect(
        () => DocumentoAnalizado.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'id')),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['creadoEn'] = '10 de agosto';
      expect(
        () => DocumentoAnalizado.fromJson(json),
        throwsA(isA<CampoInvalido>()),
      );
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['creadoEn'], '2026-08-10T19:05:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos documentos con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos documentos con los mismos datos comparten hashCode', () {
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos documentos con estados distintos NO son iguales', () {
      expect(
        ejemplo(estado: Cargado(DateTime.utc(2026, 8, 10, 19, 5))),
        isNot(equals(ejemplo())),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(fotoUrl: 'https://otra.jpg');

      expect(copia.fotoUrl, 'https://otra.jpg');
      expect(copia.id, original.id);
      expect(copia.creadoEn, original.creadoEn);
    });
  });

  group('reglas de negocio', () {
    test('un documento con error se puede reanalizar', () {
      expect(
        ejemplo(estado: const ConError('imagen borrosa')).sePuedeReanalizar,
        isTrue,
      );
    });

    test('un documento analizado también se puede reanalizar', () {
      expect(ejemplo().sePuedeReanalizar, isTrue);
    });

    test('un documento cargado NO se puede reanalizar', () {
      expect(
        ejemplo(estado: Cargado(DateTime.utc(2026, 8, 10, 19, 5)))
            .sePuedeReanalizar,
        isFalse,
      );
    });

    test('la etiqueta de un error incluye el motivo', () {
      expect(
        const ConError('imagen borrosa').etiqueta,
        contains('imagen borrosa'),
      );
    });
  });
}
