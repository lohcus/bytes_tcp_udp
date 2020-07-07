#!/bin/bash
#Criado por Daniel Domingues
#https://github.com/lohcus

clear

if [ -a "$1" ]
then
	bytes=$(cat $1)
else
	bytes=$1
fi

if [ ${#bytes} -lt 20 ]
then
	echo "Sequencia de bytes ou arquivo informado inválidos"
	exit 0
fi

#SEQUENCIA PARA COLORIR OS BYTES E FACILITAR A VISUALIZAÇÃO
#CAMADA 2
aux=$(echo $bytes | cut -d " " -f 1-6)
printf "\033[44;31;1m$aux \033[m"
aux=$(echo $bytes | cut -d " " -f 7-12)
printf "\033[44;37;1m$aux \033[m"
aux=$(echo $bytes | cut -d " " -f 13-14)
printf "\033[44;31;1m$aux \033[m"

#TESTA O TIPO DE PROTOCOLO UTILIZADO NA CAMADA 3
proto=$(echo $bytes | cut -d " " -f 13,14 | sed 's/ //g')
if [ $proto = "0800" ]
then
	#CAMADA 3
	#VERSION
	aux=$(echo $bytes | cut -d " " -f 15 | cut -c1)
	printf "\033[41;37;1m$aux\033[m"
	#IHL
	aux=$(echo $bytes | cut -d " " -f 15 | cut -c2)
	printf "\033[41;36;1m$aux \033[m"
	#ToS
	aux=$(echo $bytes | cut -d " " -f 16)
	printf "\033[41;37;1m$aux\n\033[m"
	#TOTAL LENGTH
	aux=$(echo $bytes | cut -d " " -f 17-18)
	printf "\033[41;36;1m$aux \033[m"
	#ID
	aux=$(echo $bytes | cut -d " " -f 19-20)
	printf "\033[41;37;1m$aux \033[m"
	#FLAGS
	aux=$(echo $bytes | cut -d " " -f 21 | cut -c1)
	printf "\033[41;36;1m$aux\033[m"
	#FRAGMENT OFFSET
	aux=$(echo $bytes | cut -d " " -f 21 | cut -c2)
	printf "\033[41;37;1m$aux \033[m"
	#TTL
	aux=$(echo $bytes | cut -d " " -f 22)
	printf "\033[41;36;1m$aux \033[m"
	#PROTOCOL
	aux=$(echo $bytes | cut -d " " -f 23)
	printf "\033[41;37;1m$aux \033[m"
	#HEADER CHECKSUM
	aux=$(echo $bytes | cut -d " " -f 24-25)
	printf "\033[41;36;1m$aux \033[m"
	#SRC ADDR
	aux=$(echo $bytes | cut -d " " -f 26-30)
	printf "\033[41;37;1m$aux \033[m"
	#DST ADDR
	aux=$(echo $bytes | cut -d " " -f 31-32)
	printf "\033[41;36;1m$aux\n\033[m"
	aux=$(echo $bytes | cut -d " " -f 33-34)
	printf "\033[41;36;1m$aux \033[m"

	#CAMADA 4
	#SRC PORT
	aux=$(echo $bytes | cut -d " " -f 35-36)
	printf "\033[42;37;1m$aux \033[m"
	#SRC PORT
	aux=$(echo $bytes | cut -d " " -f 37-38)
	printf "\033[42;31;1m$aux \033[m"
	#RESTANTE DO CABEÇALHO DA CAMADA DE TRANSPORTE
	aux=$(echo $bytes | cut -d " " -f 39-48)
	printf "\033[42;37;1m$aux\n\033[m"
	aux=$(echo $bytes | cut -d " " -f 49-64)
	printf "\033[42;37;1m$aux\n\033[m"
elif [ $proto = "0806" ]
then
	#CAMADA 3
	#HARDWARE TYPE
	aux=$(echo $bytes | cut -d " " -f 15-16)
	printf "\033[41;37;1m$aux\n\033[m"
	#PROTOCOL TYPE
	aux=$(echo $bytes | cut -d " " -f 17-18)
	printf "\033[41;36;1m$aux \033[m"
	#HARDWARE SIZE
	aux=$(echo $bytes | cut -d " " -f 19)
	printf "\033[41;37;1m$aux \033[m"
	#PROTOCOL SIZE
	aux=$(echo $bytes | cut -d " " -f 20)
	printf "\033[41;36;1m$aux \033[m"
	#OP CODE
	aux=$(echo $bytes | cut -d " " -f 21-22)
	printf "\033[41;37;1m$aux \033[m"
	#SENDER HARDWARE ADDRESS
	aux=$(echo $bytes | cut -d " " -f 23-28)
	printf "\033[41;36;1m$aux \033[m"
	#SENDER PROTOCOL ADDRESS
	aux=$(echo $bytes | cut -d " " -f 29-32)
	printf "\033[41;37;1m$aux\n\033[m"
	#TARGET HARDWARE ADDRESS
	aux=$(echo $bytes | cut -d " " -f 33-38)
	printf "\033[41;36;1m$aux \033[m"
	#TARGET PROTOCOL ADDRESS
	aux=$(echo $bytes | cut -d " " -f 39-42)
	printf "\033[41;37;1m$aux \033[m"
fi

echo
printf "\033[32;1m==========ETHERNET==========\n\033[m"

echo -n "Dst MAC: "
aux=$(echo $bytes | cut -d " " -f 1,2,3,4,5,6)
printf "\033[33;1m$aux\n\033[m"

echo -n "Src MAC: "
aux=$(echo $bytes | cut -d " " -f 7,8,9,10,11,12)
printf "\033[33;1m$aux\n\033[m"

echo -n "EhterType: "
proto=$(echo $bytes | cut -d " " -f 13,14 | sed 's/ //g')
if [ $proto = "0800" ]
then
	printf "\033[33;1mIPv4\n\033[m"

	echo
	printf "\033[32;1m=============IP=============\n\033[m"

	echo -n "Versão: "
	aux=$(echo $bytes | cut -d " " -f 15 | cut -c1)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Tamanho do cabeçalho IP: "
	aux=$(echo $bytes | cut -d " " -f 15 | cut -c2)
	let aux=$aux*4
	ipheader=$aux
	printf "\033[33;1m$aux bytes\n\033[m"

	echo -n "Tamanho total do pacote: "
	aux=$(printf %d 0x$(echo $bytes | cut -d " " -f 17,18 | sed 's/ //g'))
	printf "\033[33;1m$aux bytes\n\033[m"

	echo -n "ID: "
	id=$(echo $bytes | cut -d " " -f 19,20 | sed 's/ //g')
	aux=$(printf "%d\n" 0x$id)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Flag: "
	flag=$(echo $bytes | cut -d " " -f 21 | cut -c1)
	if [ $flag = "2" ]
	then
		printf "\033[33;1mMore fragments\n\033[m"
	elif [ $flag = "4" ]
	then
		printf "\033[33;1mDon't fragment\n\033[m"
	else
		printf "\033[33;1mNo flag set\n\033[m"
	fi
	echo -n "Offset: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f 21,22 | sed 's/ //g' | cut -c2,3,4))
	printf "\033[33;1m$aux\n\033[m"


	echo -n "TTL: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f 23))
	printf "\033[33;1m$aux\n\033[m"


	echo -n "Protocolo: "
	proto=$(echo $bytes | cut -d " " -f 24)
	if [ $proto = "01" ]
	then
		printf "\033[33;1mICMP\n\033[m"
		proto="ICMP"
	elif [ $proto = "06" ]
	then
		printf "\033[33;1mTCP\n\033[m"
		proto="TCP"
	elif [ $proto = "11" ]
	then
		printf "\033[33;1mUDP\n\033[m"
		proto="UDP"
	else
		echo "Procure o protocolo $proto em /etc/protocols"
	fi

	echo -n "Src IP: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f 27) 0x$(echo $bytes | cut -d " " -f 28) 0x$(echo $bytes | cut -d " " -f 29)  0x$(echo $bytes | cut -d " " -f 30))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Dst IP: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f 31) 0x$(echo $bytes | cut -d " " -f 32) 0x$(echo $bytes | cut -d " " -f 33)  0x$(echo $bytes | cut -d " " -f 34))
	printf "\033[33;1m$aux\n\033[m"

	echo
#=======================================TCP=======================================
	if [ $proto = "TCP" ]
	then
		printf "\033[32;1m===========T C P=============\n\033[m"

		echo -n "Src port: "
		aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(($ipheader+15)),$(($ipheader+15+1)) | sed 's/ //g'))
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Dst port: "
		aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(($ipheader+15+2)),$(($ipheader+15+3)) | sed 's/ //g'))
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Seq number: "
		aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(($ipheader+15+4))-$(($ipheader+15+7)) | sed 's/ //g'))
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Ack number: "
		aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(($ipheader+15+8))-$(($ipheader+15+11)) | sed 's/ //g'))
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Tamanho do cabeçalho TCP: "
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15+12)) | cut -c1)
		aux=$(printf %d 0x$aux)
		let aux=$aux*4
		tcpheader=$aux
		printf "\033[33;1m$aux bytes\n\033[m"

		echo "Flags: U A P R S F"
		echo "       R C S S Y I"
		echo "       G K H T N N"
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15+12)),$(($ipheader+15+13)) | cut -c2-5 | sed 's/ //g')
		flag=$(echo "obase=2; ibase=16; $aux" | bc)
		aux=0" $(echo -n "$flag" | cut -c1)"
		aux=$aux" $(echo -n " $flag" | cut -c3)"
		aux=$aux" $(echo -n " $flag" | cut -c4)"
		aux=$aux" $(echo -n " $flag" | cut -c5)"
		aux=$aux" $(echo -n " $flag" | cut -c6)"
		printf "\033[33;1m       $aux\n\033[m"

		#LEITURA DO PAYLOAD
		echo
		printf "\033[32;1m==========PAYLOAD============\n\033[m"
		bytes=$(echo $bytes | cut -d " " -f $((15+$ipheader+$tcpheader))-)
		for b in $bytes
		do
		        printf "\033[33;1m\x$b\033[m"
		        sleep 0.005
		done
#=======================================UDP=======================================
	elif [ $proto = "UDP" ]
	then
		printf "\033[32;1m===========U D P=============\n\033[m"
		echo -n "Src port: "
		aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(($ipheader+15)),$(($ipheader+15+1)) | sed 's/ //g'))
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Dst port: "
		aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(($ipheader+15+2)),$(($ipheader+15+3)) | sed 's/ //g'))
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Tamanho do cabeçalho UDP: "
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15+4)),$(($ipheader+15+5)) | sed 's/ //g')
		aux=$(printf %d 0x$aux)
		udpheader=$aux
		printf "\033[33;1m$aux bytes\n\033[m"

		#LEITURA DO PAYLOAD
		echo
		printf "\033[32;1m==========PAYLOAD============\n\033[m"
		bytes=$(echo $bytes | cut -d " " -f $((15+$ipheader+8))-)
		for b in $bytes
		do
		        printf "\033[33;1m\x$b\033[m"
		        sleep 0.005
		done
#=======================================ICMP=======================================
	elif [ $proto = "ICMP" ]
	then
		printf "\033[32;1m===========ICMP=============\n\033[m"
		echo -n "Type: "
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15)))
		if [ $aux = "01" ]
		then
			printf "\033[33;1mEcho Reply (1)\n\033[m"
		elif [ $aux = "03" ]
		then
			printf "\033[33;1mDestination Unreachable (3)\n\033[m"
		elif [ $aux = "08" ]
		then
			printf "\033[33;1mEcho Request (8)\n\033[m"
		elif [ $aux = "11" ]
		then
			printf "\033[33;1mTime Exceeded (11)\n\033[m"
		else
			printf "\033[33;1mOp Code não reconhecido ($aux)\n\033[m"
		fi

		echo -n "Code: "
		aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(($ipheader+15+1))))
		printf "\033[33;1m$aux - Verifique em https://pt.wikipedia.org/wiki/Internet_Control_Message_Protocol\n\033[m"

		echo -n "ID BE: "
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15+4)),$(($ipheader+15+5)) | sed 's/ //g')
		aux=$(printf %d 0x$aux)
		printf "\033[33;1m$aux\n\033[m"

		echo -n "ID LE: "
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15+5)))
		aux=$aux$(echo $bytes | cut -d " " -f $(($ipheader+15+4)))
		aux=$(printf %d 0x$aux)
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Seq number BE: "
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15+6)),$(($ipheader+15+7)) | sed 's/ //g')
		aux=$(printf %d 0x$aux)
		printf "\033[33;1m$aux\n\033[m"

		echo -n "Seq number LE: "
		aux=$(echo $bytes | cut -d " " -f $(($ipheader+15+7)))
		aux=$aux$(echo $bytes | cut -d " " -f $(($ipheader+15+6)))
		aux=$(printf %d 0x$aux)
		printf "\033[33;1m$aux\n\033[m"
	fi
#=======================================ARP=======================================
elif [ $proto = "0806" ]
then
	printf "\033[33;1mARP\n\033[m"

	echo
	printf "\033[32;1m=============ARP=============\n\033[m"

	echo -n "Hardware Type: "
	aux=$(echo $bytes | cut -d " " -f 15-16 | sed 's/ //g')
	if [ $aux = "0001" ]
	then
		printf "\033[33;1mEthernet\n\033[m"
	else
		printf "\033[33;1mVerifique em https://www.iana.org/assignments/arp-parameters/arp-parameters.xhtml o tipo de hardware número $aux\n\033[m"
	fi

	echo -n "Protocol Type: "
	aux=$(echo $bytes | cut -d " " -f 17-18 | sed 's/ //g')
	if [ $aux = "0800" ]
	then
		printf "\033[33;1mIPv4\n\033[m"
	else
		printf "\033[33;1mVerifique em https://www.wikiwand.com/en/EtherType o tipo de protocolo número $aux\n\033[m"
	fi

	echo -n "Hardware Address Length: "
	aux=$(echo $bytes | cut -d " " -f 19)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Protocol Address Length: "
	aux=$(echo $bytes | cut -d " " -f 20)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Op Code: "
	aux=$(echo $bytes | cut -d " " -f 21-22 | sed 's/ //g')
	if [ $aux = "0001" ]
	then
		printf "\033[33;1mRequest (1)\n\033[m"
	elif [ $aux = "0002" ]
	then
		printf "\033[33;1mReply (2)\n\033[m"
	else
		printf "\033[33;1mOp Code não reconhecido ($aux)\n\033[m"
	fi

	echo -n "Sender MAC Address: "
	aux=$(echo $bytes | cut -d " " -f 23-28)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Sender Protocol Adress: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f 29) 0x$(echo $bytes | cut -d " " -f 30) 0x$(echo $bytes | cut -d " " -f 31)  0x$(echo $bytes | cut -d " " -f 32))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Target MAC Address: "
	aux=$(echo $bytes | cut -d " " -f 33-38)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Target Protocol Adress: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f 39) 0x$(echo $bytes | cut -d " " -f 40) 0x$(echo $bytes | cut -d " " -f 41)  0x$(echo $bytes | cut -d " " -f 42))
	printf "\033[33;1m$aux\n\033[m"

	#LEITURA DO PAYLOAD
	echo
	printf "\033[32;1m==========PAYLOAD============\n\033[m"
	bytes=$(echo $bytes | cut -d " " -f 43-)
	for b in $bytes
	do
	        printf "\033[33;1m\x$b\033[m"
	        sleep 0.005
	done
elif [ $proto = "86DD" ]
then
	printf "\033[33;1mIPv6\n\033[m"
	printf "\033[32;1mESTE SCRIPT SUPORTA APENAS IPv4 e ARP!\n\033[m"
	echo
	exit 0
else
	printf "\033[33;1m$proto\n\033[m"
	printf "\033[32;1mESTE SCRIPT SUPORTA APENAS IPv4 e ARP!\n\033[m"
	echo
	exit 0
fi
echo
