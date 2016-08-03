#!/bin/bash
# --========================================================================--
# net_map.sh: Um simples programa para o mapeamento de host ativos rede
# 
# Mateus Sousa, Junho 2016 
# 
# Versao 1 Realiza o scaneamento da rede utilizando a ferramenta ping.
#
# Versao 2 Realiza o scaneamento da rede utilizando a ferramenta ping e 
# o scaneamento de portas.
#
# Licenca GPL
#
# TODO: Documentar este codigo.
#
# --========================================================================--

clear
declare -a lista
declare -a vetor
declare -a TARGETS

echo -e "\t#################### NET DISCOVER FOR LINUX ####################"
echo -e "\t########################/ / /   \ \ \  ######################"
echo -e "\t########################\ \ \   / / /  ######################"
echo -e "\t ########################     ||    ########################"
echo -e "\t ########################     ||    ########################"
echo -e "\t ########################   __||__  ########################"
echo  -e "\t\t\t\t\t 	by Mateus Sousa (n00b)"

if which ip &> /dev/null
then
	interfaces=$(ip addr show)
	cont=0
	if grep -i "eth0" <<< $interfaces &> /dev/null
	then
	   lista[$cont]="eth0"
	   let cont++
	fi
	
	if grep -i "eth1" <<< $interfaces &> /dev/null
	then
	   lista[$cont]="eth1"
	   let cont++
	fi

	if grep -i "wlan0" <<< $interfaces &> /dev/null
	then
	      lista[$cont]="wlan0"

	      let cont++
	fi
	if grep -i 'br0' <<< $interfaces &> /dev/null
	then
		lista[$cont]='br0'
		let cont++
	fi

	echo -e "Current interfaces: ${lista[@]}"
	read -p "Choose a interface to map: " int

	IP=$(/bin/ip addr show $int | grep 'inet ' | awk '{print $2}' | sed 's/\/.*//')
	/bin/ip addr show $int | grep 'inet ' | awk '{print $2}' | sed 's/\/.*//'	
	
	echo -e "Your IP is $IP\n"	
	read -p "Choose a range of IPs, e.g. from-to: " range
	from=$(cut -d- -f 1	<<< $range)
	to=$(cut -d- -f 2 <<< $range)
	[ -z "$to" ] && to=$from
	echo "Starting..."

	if grep $int <<< ${lista[@]} &> /dev/null
	then
		for x in {1..4}
		do
			vetor[$x]=$(cut -d. -f $x <<< $IP)

		done
		CONT=0
		for sufx in $(seq $from 1 $to)
		do
			new_ip=$(tr ' ' . <<< ${vetor[@]:1:3})
			ping -c2 -W2 "$new_ip.$sufx" &> /dev/null

	  		[ $? -eq 0 ] && echo "$new_ip.$sufx ativo" && TARGETS[$CONT]="$new_ip.$sufx" && let CONT++
		done
		[ ${#TARGETS} -eq 0 ] && echo "No hosts found! Exiting..." && exit 2
		read -p "Do the port scanning at a target host (y|n)? " YN
		YN=$(tr A-Z a-z <<< $YN)
		if [ $YN = 'y' ]
		then
			clear
			echo -e "\nYou have the following targets:\n"
			for x in ${!TARGETS[@]}
			do			
				echo "$x - ${TARGETS[$x]}"
				
		done
		echo " "
		read -p "Choose a target: " FOO

		if grep ${TARGETS[$FOO]} <<< "${TARGETS[@]}" &> /dev/null
		then
			clear
			echo -e "Start scanning...\n"
			nc -v -z "${TARGETS[$FOO]}" 22-5555 

		else
			echo "Invalid target! Try again."			
		fi
		fi
	else
		echo "Error! Try again."

	fi
##################### CASE IFCONFIG #####################
elif which ifconfig &> /dev/null
then
	interfaces=$(ifconfig)
	if grep -i "eth0" <<< $interfaces &> /dev/null
	then
	   lista[$cont]="eth0"
	   let cont++
	fi
	
	if grep -i "eth1" <<< $interfaces &> /dev/null
	then
	   lista[$cont]="eth1"
	   let cont++
	fi

	if grep -i "wlan0" <<< $interfaces &> /dev/null
	then
	      lista[$cont]="wlan0"

	      let cont++
	fi

	echo -e "Current interfaces: ${lista[@]}"
	read -p "Choose a interface to map: " int
	read -p "Choose a range of IPs, e.g. from-to: " range
	from=$(cut -d- -f 1	<<< $range)
	to=$(cut -d- -f 2 <<< $range)
	if grep $int <<< ${lista[@]} &> /dev/null
	then
		IP=$(/sbin/ifconfig $int | grep 'inet ' | awk '{print $3}')
		echo -e "Your IP is $IP\nScanning the network...\n"
		for x in {1..4}
		do
			vetor[$x]=$(cut -d. -f $x <<< $IP)
		done
		for sufx in $(seq $from 1 $to)
		do
			new_ip=$(tr ' ' . <<< ${vetor[@]:1:3})
			ping -c2 -W2 "$new_ip.$sufx" &> /dev/null
	  		[ $? -eq 0 ] && echo "$new_ip.$sufx ativo"
		done		
	else
		echo "Error! Try again."

	fi
fi
