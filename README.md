# Vía Justa

App para reportar precios de productos y servicios por zona, detectando posibles anomalías estadísticas. Proyecto universitario — sexto semestre, 2 estudiantes, 4 meses.

## El dominio

- `ReportePrecio` — entidad principal. Identidad: `id`.
- `Monto` — objeto de valor (cantidad + moneda).
- `EstadoReporte` — sellada: Borrador · Enviado · Verificado · Rechazado.

Decisión: modelo escrito a mano, porque conserva mensajes de error descriptivos (`CampoInvalido`) que freezed reemplaza por genéricos.

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run
