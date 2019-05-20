# Autoras: Lucía Cristóbal Yagüe y Paula Iglesias Reina
# NIP: 764641 y 758416
# Script de la practica 5 de AS

#!/bin/bash
if [ $# != 1 ] ; then
		echo "Usage: $(basename $0) <IP>"
		exit 1
fi
echo Conectando a la IP "$1" ...
ssh as@"$1"  -n  >/dev/null 2>&1
if [ $? = 0 ] ; then 
	echo Conectado a la IP "$1"
	echo "Discos duros y tamanos (en bloques):"
	ssh -n as@"$1" sudo sfdisk -s
	echo "Particiones y tamanos (en bloques):"
	ssh -n as@"$1" sudo sfdisk -l
	echo -e "Particion/vol. logico, tipo sistema ficheros, direccion, tamano y espacio libre:\n"
	ssh -n as@"$1" df -hT
else 
	echo "Error: IP $1 invalida o imposible de conectar"
fi
