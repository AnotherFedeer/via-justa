import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:primer_app/features/documentos/data/documentos_locales.dart';

const _json = '''
[
  {
    "id": "doc-001",
    "fotoUrl": "https://ejemplo.co/fotos/contrato1.jpg",
    "creadoEn": "2026-08-10T19:05:00Z",
    "estado": { "tipo": "cargado", "cargadoEn": "2026-08-10T19:05:00Z" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = DocumentosLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodos()).length, 1);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = DocumentosLocales(lector: (_) async => _json);

    expect(
      (await repo.obtenerPorId('doc-001'))?.fotoUrl,
      'https://ejemplo.co/fotos/contrato1.jpg',
    );
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = DocumentosLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodos(), throwsA(isA<Exception>()));
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = DocumentosLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodos()).length, greaterThanOrEqualTo(3));
    },
  );
}
