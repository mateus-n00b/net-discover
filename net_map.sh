#!/bin/bash
# --========================================================================--
# net_map.sh: Um simples programa para o mapeamento de host ativos rede
# 
# Mateus Sousa, Junho 2016 
# 
# Versao 1.0 Realiza o escaneamento da rede utilizando a ferramenta ping.
#
# Versao 1.1 Realiza o escaneamento da rede utilizando a ferramenta ping e 
# o escaneamento de portas.
#
# Mateus Sousa, Agosto 2016 
#
# Versao 1.2
# 
# + Adicionei a descoberta de interfaces de forma automatica.
#
# Licenca GPL
#
# TODO: Documentar este codigo.
#
# --========================================================================--

clear
declare -a vetor
declare -a TARGETS

# ASCII art
echo -e "\t#################### NET DISCOVER FOR LINUX ####################"
echo -e "\t########################/ / /   \ \ \  ######################"
echo -e "\t########################\ \ \   / / /  ######################"
echo -e "\t ########################     ||    ########################"
echo -e "\t ########################     ||    ########################"
echo -e "\t ########################   __||__  ########################"
echo  -e "\t\t\t\t\t 	by Mateus Sousa (N00B)"

if which ip &> /dev/null
then
	interfaces=$(ip addr show | awk -F': ' '{print $2}' | tr '\n' ' ')
	echo -e "Current interfaces: $interfaces"
	read -p "Choose a interface to map: " int

	IP=$(/bin/ip addr show $int | grep 'inet ' | awk '{print $2}' | sed 's/\/.*//')

    [ -z "$IP" ] && echo "No IP was found! Exiting..." && exit 2		
	
	echo -e "Your IP is $IP\n"	
	read -p "Choose a range of IPs, e.g. from-to: " range
	from=$(cut -d- -f 1	<<< $range)
	to=$(cut -d- -f 2 <<< $range)

    [ -z "$to" -a -z "$from" ] && echo "Invalid range! Exiting..." && exit 2    
	[ -z "$to" ] && to=$from
	echo "Starting..."

# Armazeno em vetor os tres primeiros octetos	
for x in {1..4}
do
	vetor[$x]=$(cut -d. -f $x <<< $IP)
done

CONT=0
# Itero pelos sufixos passados no range
for sufx in $(seq $from 1 $to)
do
	# Pego os tres primeiros octetos XXX.XXX.XXX
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

# Testo se o alvo existe
if grep ${TARGETS[$FOO]} <<< "${TARGETS[@]}" &> /dev/null
then
	clear
	#Aqui inicio o escaneamento das portas
	echo -e "Start scanning...\nThis should take a long time..."
	for x in {1..2222}
	do
		nc -z -v ${TARGETS[$FOO]} $x &> /dev/null
		[ $? -eq 0 ] && echo "Port $x open" >> /tmp/open_ports.txt
	done
	echo "The result it's in /tmp/open_ports."
else
	echo "Invalid target! Try again."
	exit 2			
fi
fi
fi
##################### CASE IFCONFIG #####################
