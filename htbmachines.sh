#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT 

#Variables Globales
bundleurl="https://htbmachines.github.io/bundle.js"

function ctrl_c() { 
	echo -e "\n${redColour} Saliendo...${endColour}\n"
	tput cnorm;exit 1
}

function helpPanel() { 
	echo -e "\n\t${redColour} Uso ./htbmachines.sh${endColour}\n"
	for i in {0..140}; do echo -ne "${redColour}-${endColour}"; done
	echo -e "\n"
	echo -e "\t\t${grayColour}m)${endColour}${yellowColour} Realizar la busqueda de una maquina${endColour}\n"
	echo -e "\t\t${grayColour}i)${endColour}${yellowColour} Buscar por dirección IP${endColour}\n"
	echo -e "\t\t${grayColour}y)${endColour}${yellowColour} Obtener link de la resolución de la máquina en youtube${endColour}\n"
	echo -e "\t\t${grayColour}d)${endColour}${yellowColour} Buscar por la dificultad de la máquina${endColour}\n"
	echo -e "\t\t${grayColour}o)${endColour}${yellowColour} Buscar por el Sistema Operativo${endColour}\n"
	echo -e "\t\t${grayColour}s)${endColour}${yellowColour} Buscar por Skills${endColour}\n"
	echo -e "\t\t${grayColour}u)${endColour}${yellowColour} Realizar Actualizacion de Bundle${endColour}\n"
	echo -e "\t\t${grayColour}h)${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n"
}

function searchMachine() {
	tput civis
	machineName=$1
	echo -e "\n${grayColour}[*]${endColour}${greenColour} Listando propiedades de la maquina ...$machineName${endColour}\n"
	cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ *//g' | while IFS= read -r line; do 
	key=$(echo "$line" | cut -d ':' -f1)   # Extraer la clave (columna izquierda)
        value=$(echo "$line" | cut -d ':' -f2-) # Extraer el valor (columna derecha)
        echo -e "${grayColour}${key}:${endColour} ${blueColour}${value}${endColour}"
    done > prueba.tmp 
	if [ "$(cat prueba.tmp | wc -l)" == "0" ]; then 
		sleep 1; echo -e "${redColour}[*]${endColour}${yellowColour} Maquina $machineName no encontrada${endColour}" 
	else 
		sleep 1; cat prueba.tmp
	fi
	tput cnorm
	rm prueba.tmp
}

function updatefiles() {
	tput civis
	echo -e "\n${blueColour}[*]${endColour}${yellowColour} Comprobando si existe el archivo Bundle ...${endColour}"
	if [ ! -f bundle.js ]; then 
	sleep 2;echo -e "\n${blueColour}[*]${endColour}${yellowColour} Archivo Inexistente, Descargando ...${endColour}"
	curl -s "$bundleurl" > bundle.js
	js-beautify bundle.js | sponge bundle.js
	else
	sleep 2;echo -e "\n${redColour}[*]${endColour}${yellowColour} Realizando Actualización ...${endColour}"
	curl -s "$bundleurl" > bundle_temp.js 
	js-beautify bundle_temp.js | sponge bundle_temp.js
	md5temp=$(md5sum bundle_temp.js | awk '{print $1}')
	md5bundle=$(md5sum bundle.js | awk '{print $1}')
	if [ "$md5tmep" == "$md5bundle" ]; then 
	echo -e "${grayColour}[*]${endColour}${greenColour} Archivo Actualizado${endColour}" 
	else 
	rm bundle.js && mv bundle_temp.js bundle.js
	echo -e "\n${grayColour}[*]${endColour}${greenColour} Archivo Actualizado${endColour}\n" 
	fi
	fi
	tput cnorm
}

function searchIP() {
	tput civis
	ipAddress="$1"
	machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B3 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '""')"
	echo "$machineName" > validatorIP.tmp
	if [ "$(cat validatorIP.tmp | wc -w)" == "1" ]; then 
	sleep 1; echo -e "\n${prupleColour}[*]${endColour}${yellowColour} El nombre de la maquina con IP ${blueColour}$ipAddress${endColour}${yellowColour} es${endColour}${greenColour} $machineName${endColour}\n"
	else
	sleep 1; echo -e "\n${redColour}[*]${endColour}${grayColour} Direccion IP${yellowColour} $ipAddress${endColour}${redColour} No valida${endColour}\n"
	fi
	rm validatorIP.tmp 
	tput cnorm
} 

function getYoutubeLink() {
	tput civis
	machineName="$1"

	youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ *//g' | grep "youtube" | awk 'NF{print $NF}')"
	if [ $youtubeLink ]; then
	sleep 1; echo -e "\n${greenColour}[*]${endColour}${yellowColour} El tutorial para la maquina ${endColour}${greenColour}$machineName${endColour}${yellowColour} Esta en el siguiente enlace: ${endColour}${redColour}$youtubeLink${endColour}\n"
	else
	sleep 1; echo -e "\n${redColour}[*]${endColour}${yellowColour} Máquina No Encontrada${endColour}\n"
	fi
	tput cnorm
}

function getMachinesDifficulty() {
	difficulty="$1"

	getdifficulty="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '""'| column)"
	if [ "$getdifficulty" ]; then
	 echo -e "\n${yelloColour}[*]${endColour}${redColour} Mostrando máquinas con dificultad:${endColour}${blueColour} $difficulty${endColour}\n"
	echo -e "${grayColour}$getdifficulty${endColour}"
	else
	echo -e "\n${redColour}[*]${endColour}${yellowColour} Dificultad no encontrada${endColour}\n"
	fi
}

function getOSMachines() {
	os="$1"

	os_results="$(cat bundle.js | grep  -i "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column)"
	if [ "$os_results" ]; then
	echo -e "\n${greenColour}[*]${endColour}${yellowColour} Mostrando máquinas cuyo Sistema Operativo es:${endColour}${blueColour} $os${endColour}\n"
	echo -e "${yellowColour}$os_results${endColour}"
	else
	echo -e "\n${redColour}[*]${endColour}${yellowColour} Sistema Operativo no encontrado${endColour}\n"
	fi
}

function getOSDifficultyMachines () {
	difficulty="$1"
	os="$2"
	os_difficulty="$(cat bundle.js | grep -i "so: \"$os\"" -C5 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column)"
	if [ "$os_difficulty" ]; then
	echo -e "\n${greenColour}[*]${endColour}${yellowColour} Listando dificultad ${endColour}${greenColour}$difficulty${endColour}${yellowColour} y Sistema Operativo${endColour}${greenColour} $os:${endColour}\n"
	echo -e "${purpleColour}$os_difficulty${endColour}"  
	else 
	echo -e "\n${redColour}[*]${endColour}${yellowColour} Sistema Operativo o Dificultad no encontrados${endColour}\n"
	fi
}

function getSkill() {
	skill="$1" 
	getskill="$(cat bundle.js | grep "skills: " -B6 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column)"
	if [ "$getskill" ]; then 
	echo -e "\n${greenColour}[*]${yellowColour} Listando maquinas con skill ${endColour}${greenColour}$skill${endColour}${yellowColour}:${endColour}\n"
	echo -e "${blueColour}$getskill${endColour}"
	else
	echo -e "\n${redColour}[*]${endColour}${yellowColour} Skill no encontrada${endColour}\n"
	fi
}

#Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

declare -i parameter_counter=0; while getopts "m:ui:y:d:o:s:h" arg; do
	case $arg in 
	m) machineName="$OPTARG"; let parameter_counter+=1 ;; 
	u) let parameter_counter+=2 ;;
	i) ipAddress="$OPTARG"; let parameter_counter+=3 ;;
	y) machineName="$OPTARG"; let parameter_counter+=4 ;;
	d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
	o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
	s) skill="$OPTARG"; let parameter_counter+=7;;
	h) ;;
	esac
done 

if [ $parameter_counter -eq 1 ]; then 
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then 
	updatefiles
elif [ $parameter_counter -eq 3 ]; then 
	searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then 
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
	getSkill "$skill"
elif [[ $chivato_difficulty -eq 1 && $chivato_os -eq 1 ]]; then
	getOSDifficultyMachines $difficulty $os
else
	helpPanel 
fi

