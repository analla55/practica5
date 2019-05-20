# Autoras: Lucía Cristóbal Yagüe y Paula Iglesias Reina
# NIP: 764641 y 758416
# Script de la practica 5 de AS

#!/bin/bash

if [ $# -lt 3 ]; then
	echo "Usage: $(basename $0) <ip> <volume_group> <disk_partition>"
	exit 89
fi
ip="$1"
vg="$2"
shift 2

# Se comprueba que el volume_group existe
scan=$(ssh -n as@"${ip}" sudo vgscan)
echo ${scan} | grep " \"${vg}\" " >/dev/null 2>&1
if [ $? -ne 0 ] ; then								
	echo "${vg} does not exist"
	exit 1
fi

for var in "$@"
do
	ssh -n "as@${ip}" mount | grep "^${var}" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "La partición ${var} debe desmontarse antes de ser añadida a ${vg}"
		continue
	fi

	ssh -n "as@${ip}" sudo pvs | grep "${var}" >/dev/null 2>&1
	if [ $? -eq 0 ] ; then
		echo "Ya existe el grupo físico ${var} y dentro de ${vg}"
	else
		ssh -n "as@${ip}" sudo pvcreate -y "${var}" >/dev/null 2>&1
	
		if [ $? -eq 0 ] ; then
			echo "Grupo físico ${var} creado correctamente"
		else
			echo "No se ha podido crear el grupo fisico ${var} - $"
			continue
		fi
		# Se extiende el grupovolumen
		ssh -n "as@${ip}" sudo vgextend -y "${vg}" "${var}" >/dev/null 2>&1
		# Comprobación de que funciona bien
		if [ $? -eq 0 ] ; then
			echo "Particion ${var} anadida al grupo 
			${vg} correctamente"
		else
			echo "No se ha podido anadir la particion ${var} al grupo ${vg} o particion ya creada"
		fi
	fi
done
