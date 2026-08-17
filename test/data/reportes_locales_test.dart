import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:primer_app/features/reportes/data/reportes_locales.dart';

const _json = '''
[
  {
    "id": "rp-001",
    "categoria": "transporte",
    "monto": { "cantidad": 4500, "moneda": "COP" },
    "ubicacion": "Valledupar, Barrio Centro",
    "creadoEn": "2026-08-10T19:05:00Z",
    "estado": { "tipo": "borrador" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = ReportesLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodos()).length, 1);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = ReportesLocales(lector: (_) async => _json);

    expect((await repo.obtenerPorId('rp-001'))?.categoria, 'transporte');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = ReportesLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodos(), throwsA(isA<Exception>()));
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = ReportesLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodos()).length, greaterThanOrEqualTo(3));
    },
  );
}
