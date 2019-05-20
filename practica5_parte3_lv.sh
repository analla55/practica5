# Autoras: Lucía Cristóbal Yagüe y Paula Iglesias Reina
# NIP: 764641 y 758416
# Script de la practica 5 de AS

#!/bin/bash
if [ $# -ne 6 ]; then
	echo "Usage: $(basename $0) <ip> <volume_group> <logic_volume> <size> <file_system_type> <mount_dir>"
	exit 1
fi

ip=$1
shift
volume_group=$1
logic_volume=$2
size=$3
file_system_type=$4
mount_dir=$5

$(ssh -n as@"${ip}" sudo vgscan| grep " \"${volume_group}\" " >/dev/null 2>&1)
if [ $? -ne 0 ]; then
	echo EL grupo volumen $volume_group no existe
	exit 1
fi

$(ssh -n as@"${ip}" sudo lvscan| grep "${logic_volume}" >/dev/null 2>&1)
if [ $? -ne 0 ]; then
	# Crear el volumen lógico
	ssh -n  as@"${ip}" sudo lvcreate -L "${size}" -n "${logic_volume}" "${volume_group}" >/dev/null 2>&1
	
	# Dar formato al volumen lógico
	ssh -n  as@"${ip}" sudo mkfs -t "${file_system_type} /dev/${volume_group}/${logic_volume}" >/dev/null 2>&1
	
	# El volumen lógico ya está listo para el montaje
	ssh -n  as@"${ip}" sudo mount -t "${file_system_type} /dev/${volume_group}/${logic_volume} /${mount_dir}">/dev/null 2>&1
	
	# Modificar el fichero /etc/fstab para modificar el arranque 
	# del sistema
	echo "/dev/${volume_group}/${logic_volume}	${mount_dir}	${file_system_type}		defaults	0	2" | ssh "as@$ip" sudo tee -a /etc/fstab >/dev/null 2>&1
	
	if [ $? -eq 0 ] ; then
		echo "Volumen logico creado y preparado para su montaje en el arranque"
	else
		echo "No se ha podido añadir el volumen lógico ${logic_volume} a /etc/fstab"
	fi
else 
	#Extender el volumen lógico el tamaño indicado
	ssh -n  as@"${ip}" sudo lvextend -L+${size} "/dev/${volume_group}/${logic_volume}" > /dev/null 2>&1
	
	#Extender el sistema de ficheros del lv correspondiente
	ssh -n  as@"${ip}" sudo resize2fs "/dev/${volume_group}/${logic_volume}" > /dev/null 2>&1
	if [ $? -eq 0 ] ; then
		echo "Sistema de ficheros /dev/${volume_group}/${logic_volume} extendido correctamente"
	else
		echo "No se ha podido extender el sistema de ficheros /dev/${volume_group}/${logic_volume}"
	fi
fi
