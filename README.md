# temperature-watermark
This repository contains the R script to read watermark temperature values from camera trap images in projects of Ecology and Conservation

[English version on the way...]

Este repositorio contiene el script de R para la lectura de los valores de temperatura de las imágenes obtenidas por cámaras trampa en proyectos de Ecología y Conservación. El script lo desarrollé durante mi estancia en el Centro para el Estudio y Conservación de las Aves Rapaces en Argentina (CECARA).

Las cámaras de fototrampeo guardan información en los metadatos de las imágenes, que pueden ser extraídos automáticamente. Sin embargo, hay ocasiones en que cierta información, como los valores de temperatura, se guarda como marca de agua en la propia imagen pero no en los metadatos. La extracción manual de estos valores de temperatura para su posterior análisis requiere de una gran inversión de tiempo cuando se dispone de una gran cantidad de imágenes. Como solución, se puede automatizar el proceso mediante Optical Character Recognition (OCR). Este script permite la lectura de los valores de temperatura utilizando el paquete "tesseract" tras procesar las imágenes mediante el paquete "magick".

El script es imperfecto y por el momento tiene las siguientes limitaciones:

- Está diseñado para cierto tipo de cámaras. Las coordenadas del lugar en el que aparece la marca de agua con el valor de temperatura en la imagen cambian entre diferentes cámaras y diferentes configuraciones de la misma cámara. Cada tipo de imagen requiere de un procesamiento (recorte y aumento) diferente. El script actual está diseñado utilizando Browning Wildlife Cameras, y además para determinadas configuraciones (calidad de imagen, altura de la franja donde aparece la marca de agua de la temperatura...). He incluido tantos tipos de imagen como procesé, pero con nuevas configuraciones de cámara habrá nuevos tipos que aún no estén incluidos.

- Solo lee temperaturas del rango 10 – 59 C.

- La lectura es imperfecta y en ocasiones puede confundir números (por ejemplo, leer un 1 como un 7) o no reconocer ciertos números (parece que en ocasiones le cuesta reconocer los dígitos 1 y 5). Por lo tanto, al extraer los valores de temperatura, habrá algunos valores en blanco (NA) que habrá que extraer manualmente y, en ocasiones, valores erróneos. He intentado al máximo dar preferencia a, antes de poner un número erróneo, dejar el valor en blanco. Aun así, considerar que existe la posibilidad de que haya algún valor erróneo.
