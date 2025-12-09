# Panel Led cambiador de imagen

Esto proyecto es extensión de la [versión de 8bpp](https://github.com/Fdiaz718/Panel-Led-8bpp) para una matriz led de 64x64 controlada por un FPGA 5a-75e.

Los modulos que no se mencionen aqui es porque no sufrieron cambios para este nuevo funcionamiento.

## Limitaciones
Las imagenes a cargar deben ser pasadas antes por un programa en python que convierte las 4 imagenes a mostrar en una cadena más larga de caracteres, esencialmente haciendo 4 imagenes una detras de otra. El codigo de python para generar estas imagenes esta aqui.

## Explicación modulos
### top.v
Además de coordinar el resto de modulos, ahora tambien gestiona la interacción física. Lo hace por medio de 1 contador y 1 registro de 2 bits, bastante sencillo
Conecta la salida del módulo `debounce` con el puerto de selección de `panel_memory`, permitiendo cambiar el puntero de lectura de la memoria en tiempo real.

### debounce.v
Al presionar el botón mecanico la FPGA puede tomar esto como muchas pulsaciones seguidas en un tiempo corto, esto porque generan ruido eléctrico, lo que hace este codigo es acondicionar la señal para que solo reciba 1.
Es un filtro basado en un temporizador que solo funuciona si la señal es estable durante todo el periodo.

#### panel_memory.v
La capacidad de la memoria se cuadruplico para soportar el almacenamiento de múltiples activos gráficos. La cadena de datos ya no es de 4096 (64x64) sino de 16384 palabras de 24 bits (4 imágenes de 64x64).
Utiliza la señal `image_sel` como los bits más significativos (MSB) de la dirección de memoria.
    * `sel=00`: Lee direcciones 0x0000 - 0x0FFF (Imagen 1)
    * `sel=01`: Lee direcciones 0x1000 - 0x1FFF (Imagen 2)
    * ...etc.
