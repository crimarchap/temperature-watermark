############## solo lee temperaturas entre 10 y 59 C ##############

library(magick)
library(tesseract)

### PARTE I - selección de imágenes

# ESCRIBIR la dirección de la carpeta con las imágenes y leerlas
setwd("")
files <- list.files(pattern = "*.JPG")

# ESCRIBIR el tipo de imagen
tipo <- 1

# cargar el recorte y aumento de cada tipo de imagen
# TIPO 1 - 2736 x 1520 pixels
	recorte1 <- "118x38+674+1482"
	aumento1 <- "400x"
# TIPO 2 - 3744 x 2080 pixels
	recorte2 <- "155x50+925+2030"
	aumento2 <- "620x"
# TIPO 3 - 4608 x 2560 pixels
	recorte3 <- "194x63+1139+2497"
	aumento3 <- "800x"
# TIPO 4 - 1920 x 1080 pixels, franja alta, inHg no
	recorte4 <- "96x32+473+1048"
	aumento4 <- "300x"
# TIPO 5 - 2688 x 1512 pixels, franja alta, inHg no
	recorte5 <- "131x44+665+1468"
	aumento5 <- "750x"
# TIPO 6 - 3712 x 2088 pixels, franja baja, inHg no
	recorte6 <- "120x43+920+2045"
	aumento6 <- "500x"
# TIPO 7 - 3712 x 2088 pixels, franja baja, inHg si
	recorte7 <- "200x43+925+2045"
	aumento7 <- "600x"
# TIPO 8 - 3712 x 2088 pixels, franja alta, inHg no
	recorte8 <- "180x61+920+2027"
	aumento8 <- "720x"
# TIPO 9 - 4208 x 2368 pixels, franja alta, inHg no
	recorte9 <- "206x69+1040+2299"
	aumento9 <- "800x"
# TIPO 10 - 4608 x 2592 pixels, franja baja, inHg no
	recorte10 <- "166x54+1141+2538"
	aumento10 <- "750x"
# TIPO 11 - 4608 x 2592 pixels, franja baja, inHg si, decimales no
	recorte11 <- "250x52+1150+2540"
	aumento11 <- "850x"
# TIPO 12 - 4608 x 2592 pixels, franja baja, inHg si, decimales inHg
	recorte12 <- "160x52+1075+2540"
	aumento12 <- "700x"
# TIPO 13 - 4992 x 2808 pixels, franja alta, inHg no
	recorte13 <- "241x82+1234+2726"
	aumento13 <- "850x"
# TIPO 14 - 5760 x 3240 pixels, franja baja, inHg si
	recorte14 <- "317x68+1427+3172"
	aumento14 <- "850x"

# cargar el recorte y aumento correspondientes al tipo de imagen
recorte <- get(paste0("recorte",tipo))
aumento <- get(paste0("aumento",tipo))

### PARTE II - lectura del texto de las imágenes

# crear un loop para leer las imágenes individualmete. iniciar las variables
txtsmall <- 0
txtlarge <- 0
numbers <- tesseract(options = list(tessedit_char_whitelist = "0123456789C"))

# crear el loop
for (i in seq_along(files)){
	input <- image_read(files[i])				# cargar las imágenes
	small <- image_crop(input, recorte)			# recortar el valor de temperatura
	large <- image_resize(small, aumento)		# agrandar la imagen recortada (mejor lectura)
	txtlarge[i] <- ocr(large, engine = numbers)	# leer el texto de la imagen
	txtsmall[i] <- ocr(small, engine = numbers)	# también imagen small, que ayudará a rellenar huecos
	rm(input,small,large)					# eliminar para evitar que se sature la compu
	# aquí se para un ratito :)
}

### PARTE III - eliminación de ruido del texto leído

# identificar y separar el valor de temperatura
txtlarge <- sub("C.*","",txtlarge)						# guardar solo el texto anterior al símbolo C
txtsmall <- sub("C.*","",txtsmall)
txtlarge <- gsub("[^0-9]","",txtlarge)					# guardar solo los números
txtsmall <- gsub("[^0-9]","",txtsmall)
txtlarge <- substr(txtlarge,nchar(txtlarge)-1,nchar(txtlarge))	# solo dos últimos números (símbolo termómetro lo lee como "4")
txtsmall <- substr(txtsmall,nchar(txtsmall)-1,nchar(txtsmall))
txtlarge[which(nchar(txtlarge)!=2)] <- NA					# solo los valores de dos dígitos (posibles errores)
txtsmall[which(nchar(txtsmall)!=2)] <- NA
txtlarge[txtlarge>=60] <- NA							# eliminar si el valor de t es >= 60 C (posibles errores)
txtsmall[txtsmall>=60] <- NA
txtlarge <- as.integer(txtlarge)
txtsmall <- as.integer(txtsmall)

# complementar los valores leídos en ambas imágenes y crear una tabla
Temperature <- ifelse(is.na(txtlarge),txtsmall,txtlarge)
tempe <- data.frame(files,Temperature)

### PARTE IV - errores y posibles errores

# errores de lectura. capaz que haya imágenes que no se hayan leído, chequear su id para introducirlos manualmente
errores <- tempe$files[which(is.na(tempe$Temperature),arr.ind=TRUE)]

# posibles errores de lectura. chequear la id de las imágenes donde haya habido un salto de t igual o superior a 10 C
saltos <- tempe$files[which(abs(c(NA,diff(tempe$Temperature,lag=1)))>=10,arr.ind=TRUE)]

# juntar los errores y saltos en una única tabla para exportarlos
errorsalto <- data.frame(errores=c(errores,rep("------------",max(length(errores),length(saltos))-length(errores))),saltos=c(saltos,rep("------------",max(length(errores),length(saltos))-length(saltos))))

### PARTE V - guardar

# opcional, escribir la dirección de la carpeta donde guardar las tablas
setwd("")

# guardar 1) la tabla, 2) texto id imágenes no leídas y saltos de t
write.csv2(tempe, "temperatura.csv", row.names=FALSE)
write.table(errorsalto, "errores y saltos.txt", row.names=FALSE)

### FIN ###

# el lugar o la forma en la que aparece el valor de t en la imagen cambia dependiendo del modelo de cámara
# el script está diseñado para un determinado modelo de cámara
# si el modelo de cámara cambia, crear un nuevo tipo de imagen y reajustar el recorte y aumento en PARTE I
# recorte:	[x] desde el símbolo del termómetro hasta después de C, o hasta antes de letras "inHg" en su caso
#		[y] solo la franja negra, sin llegar a incluir la parte baja de la foto
# aumento:	probar diferentes, y elegir el que de menor número de NA (aprox 4 veces el num. de pixels suele ser óptimo)
