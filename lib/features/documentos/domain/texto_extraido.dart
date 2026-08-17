import 'package:primer_app/core/json.dart';

/// Resultado del OCR sobre un documento.
///
/// Es un **objeto de valor**: dos resultados con el mismo texto y confianza son
/// el mismo resultado, así que no lleva `id` y se compara por contenido.
class TextoExtraido {
  const TextoExtraido({required this.contenido, required this.confianza});

  factory TextoExtraido.fromJson(Map<String, dynamic> json) => TextoExtraido(
    contenido: leerTexto(json, 'contenido'),
    confianza: leerDecimal(json, 'confianza'),
  );

  final String contenido;
  final double confianza;

  Map<String, dynamic> toJson() => {
    'contenido': contenido,
    'confianza': confianza,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextoExtraido &&
          other.contenido == contenido &&
          other.confianza == confianza;

  @override
  int get hashCode => Object.hash(contenido, confianza);

  @override
  String toString() => 'TextoExtraido($confianza, ${contenido.length} chars)';
}
