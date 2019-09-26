  #/bin/bash
#Criado por Daniel Domingues
#https://github.com/lohcus


clear
printf "\033[32;1m==========ETHERNET==========\n\033[m"

echo -n "Dst MAC: "
aux=$(echo $1 | cut -d " " -f 1,2,3,4,5,6)
printf "\033[33;1m$aux\n\033[m"

echo -n "Dst MAC: "
aux=$(echo $1 | cut -d " " -f 7,8,9,10,11,12)
printf "\033[33;1m$aux\n\033[m"

echo -n "EhterType: "
proto=$(echo $1 | cut -d " " -f 13,14 | sed 's/ //g')
if [ $proto = "0800" ]
then
	printf "\033[33;1mIPv4\n\033[m"
elif [ $proto = "0806" ]
then
	printf "\033[33;1mARP\n\033[m"
elif [ $proto = "86DD" ]
then
	printf "\033[33;1mIPv6\n\033[m"
else
	printf "\033[33;1m$proto\n\033[m"
fi

echo ""
printf "\033[32;1m=============IP=============\n\033[m"

echo -n "Versão: "
aux=$(echo $1 | cut -d " " -f 15 | cut -c1)
printf "\033[33;1m$aux\n\033[m"

echo -n "Tamanho do cabeçalho IP: "
aux=$(echo $1 | cut -d " " -f 15 | cut -c2)
let aux=$aux*4
printf "\033[33;1m$aux bytes\n\033[m"

echo -n "Tamanho total do pacote: "
aux=$(printf %d 0x$(echo $1 | cut -d " " -f 17,18 | sed 's/ //g'))
printf "\033[33;1m$aux bytes\n\033[m"

echo -n "ID: "
id=$(echo $1 | cut -d " " -f 19,20 | sed 's/ //g')
aux=$(printf "%d\n" 0x$id)
printf "\033[33;1m$aux\n\033[m"

echo -n "Flag: "
flag=$(echo $1 | cut -d " " -f 21 | cut -c1)
if [ $flag = "2" ]
then
	printf "\033[33;1mMore fragments\n\033[m"
	echo -n "Offset: "
	aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 21,22 | sed 's/ //g' | cut -c2,3,4))
	printf "\033[33;1m$aux\n\033[m"
elif [ $flag = "4" ]
then
	printf "\033[33;1mDon't fragment\n\033[m"
else
	printf "\033[33;1mNo flag set\n\033[m"
fi

echo -n "TTL: "
aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 23))
printf "\033[33;1m$aux\n\033[m"


echo -n "Protocolo: "
proto=$(echo $1 | cut -d " " -f 24)
if [ $proto = "06" ]
then
	printf "\033[33;1mTCP\n\033[m"
	proto="TCP"
elif [ $proto = "17" ]
then
	printf "\033[33;1mUDP\n\033[m"
	proto="UDP"
else
	echo "Procure o protocolo $proto em /etc/protocols"
fi

echo -n "Src IP: "
aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $1 | cut -d " " -f 27) 0x$(echo $1 | cut -d " " -f 28) 0x$(echo $1 | cut -d " " -f 29)  0x$(echo $1 | cut -d " " -f 30))
printf "\033[33;1m$aux\n\033[m"

echo -n "Dst IP: "
aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $1 | cut -d " " -f 31) 0x$(echo $1 | cut -d " " -f 32) 0x$(echo $1 | cut -d " " -f 33)  0x$(echo $1 | cut -d " " -f 34))
printf "\033[33;1m$aux\n\033[m"

echo ""
if [ $proto = "TCP" ]
then
	printf "\033[32;1m===========T C P=============\n\033[m"

	echo -n "Src port: "
	aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 35,36 | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Dst port: "
	aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 37,38 | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Seq number: "
	aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 39,40,41,42 | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Ack number: "
	aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 43,44,45,46 | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Tamanho do cabeçalho TCP: "
	aux=$(echo $1 | cut -d " " -f 47 | cut -c1)
	let aux=$aux*4
	printf "\033[33;1m$aux bytes\n\033[m"

	echo "Flags: U A P R S F"
	echo "       R C S S Y I"
	echo "       G K H T N N"
	flag=$(echo "obase=2; ibase=16; 0014" | bc)
	aux=0" $(echo -n "$flag" | cut -c1)"
	aux=$aux" $(echo -n " $flag" | cut -c3)"
	aux=$aux" $(echo -n " $flag" | cut -c4)"
	aux=$aux" $(echo -n " $flag" | cut -c5)"
	aux=$aux" $(echo -n " $flag" | cut -c6)"
	printf "\033[33;1m       $aux\n\033[m"

elif [ $proto = "UDP" ]
then
	printf "\033[32;1m===========U D P=============\n\033[m"
	echo -n "Src port: "
	aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 35,36 | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Dst port: "
	aux=$(printf "%d\n" 0x$(echo $1 | cut -d " " -f 37,38 | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"
else
	echo "PROTOCOLO DA CAMADA DE TRANSPORTE DIFERENTE DE TCP E UDP"
fi
