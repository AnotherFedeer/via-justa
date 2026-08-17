# Via Justa — Analisis de Documentos

App para analizar documentos (contratos, facturas) con OCR e IA, detectando anomalías y cláusulas problemáticas. Proyecto universitario — sexto semestre, 2 estudiantes, 4 meses.

## El dominio

- `DocumentoAnalizado` — entidad principal. Identidad: `id`.
- `TextoExtraido` — objeto de valor (contenido + confianza).
- `EstadoDocumento` — sellada: Cargado · Analizando · Analizado · ConError.

Decisión: modelo escrito a mano, porque conserva mensajes de error descriptivos (`CampoInvalido`) que freezed reemplaza por genéricos.

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run
