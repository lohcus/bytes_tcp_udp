#!/bin/bash
#Criado por Daniel Domingues
#https://github.com/lohcus

colunas=$(tput cols) # VERIFICA O TAMANHO DA JANELA PARA PODER DESENHAR O LAYOUT

#FUNCAO DE AJUDA
uso() {
	divisao
	printf "\033[37;1mUso: $0 -b \033[32;1mseq_bytes_ou_arquivo\033[37;1m [opcões]\n\033[m"
	printf "\033[37;1mOpcões:\n\033[m"
	printf "\033[37;1m	-h		Ajuda e modo de uso\n\033[m"
	printf "\033[37;1m	-p \033[32;1mprotocolo\033[37;1m	Protocolo mais baixo a ser analizado (Ethernet por padrão) [opcional]\n\033[m"
	printf "\033[32;1m	   ip\n\033[m"
	printf "\033[32;1m	   arp\n\033[m"
	printf "\033[32;1m	   tcp\n\033[m"
	printf "\033[32;1m	   udp\n\033[m"
	printf "\033[32;1m	   icmp\n\033[m"
	divisao
	exit 1
}
#=================================================================================================================

#FUNCAO DE DIVISORIA
divisao () {
	printf "\r\033[35;1m=\033[m"

	# LACO PARA PREENCHER UMA LINHA COM "="
	for i in $(seq 0 1 $(($colunas-2)))
	do
		printf "\033[35;1m=\033[m"
	done
	echo
}
#=================================================================================================================

clear

#CHAMA A FUNCAO PARA DESENHAR UMA DIVISORIA
divisao
echo

#VALORES PADROES
proto="ethernet"
byte=1
ipheader=1

texto="ANALIZADOR DE BYTES"
centro_coluna=$(( $(( $(( $colunas-$(echo -n $texto | wc -c) ))/2 )))) #CALCULO PARA CENTRALLIZAR O TITULO
tput cup 0 $centro_coluna #POSICIONAR O CURSOR
printf "\033[37;1m$texto\n\033[m"
divisao
texto="ESTE SCRIPT NÃO VALIDA OS DADOS DE ENTRADA! VERIFIQUE SEMPRE O RESULTADO PARA CONFIRMAR O PROTOCOLO!"
centro_coluna=$(( $(( $(( $colunas-$(echo -n $texto | wc -c) ))/2 )))) #CALCULO PARA CENTRALLIZAR O TITULO
tput cup 1 $centro_coluna #POSICIONAR O CURSOR
printf "\033[31;6m$texto\n\033[m"

# VERIFICA AS OPCOES DIGITADAS
while getopts "hb:p:" OPTION
do
	case $OPTION in
    	"h") uso
        	;;
      	"p") proto=$OPTARG
         	;;
      	"b") if [ -a "$OPTARG" ]
			 then
				bytes=$(cat $OPTARG)
			 else
				bytes=$OPTARG
			 fi
        	;;
      	"?") uso
        	;;
   esac
done
shift $((OPTIND-1))

# VERIFICA SE FORAM DIGITADOS OS PARAMETROS OBRIGATORIOS -u E -w
[ -z "$bytes" ] && uso

# UPPERCASE NO PROTOCOLO
proto=$(echo ${proto^^})

#====================================CAMADA 2====================================
if [ "$proto" = "ETHERNET" ]
then
	byte=1
	echo
	printf "\033[32;1m==========ETHERNET==========\n\033[m"

	echo -n "Dst MAC: "
	aux=$(echo $bytes | cut -d " " -f $byte-$(( $byte+5 )) | sed 's/ /:/g')
	printf "\033[33;1m$aux\n\033[m"
	
	echo -n "Src MAC: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+6 ))-$(( $byte+11 )) | sed 's/ /:/g')
	printf "\033[33;1m$aux\n\033[m"

	proto=$(echo $bytes | cut -d " " -f $(( $byte+12 ))-$(( $byte+13 )) | sed 's/ //g')
	
	#DESLOCA O PONTEIRO DE BYTES PARA A POSICAO 15
	byte=15
fi

#====================================CAMADA 3====================================
#=======================================IP=======================================
if [ "$proto" = "0800" ] || [ "$proto" = "IP" ]
then
    echo -n "EhterType: "
	printf "\033[33;1mIPv4\n\033[m"

	echo
	printf "\033[32;1m=============IP=============\n\033[m"

	echo -n "Versão: "
	aux=$(echo $bytes | cut -d " " -f $byte | cut -c1)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Tamanho do cabeçalho IP: "
	aux=$(echo $bytes | cut -d " " -f $byte | cut -c2)
	let aux=$aux*4
	ipheader=$aux
	printf "\033[33;1m$aux bytes\n\033[m"

	echo -n "Tamanho total do pacote: "
	aux=$(printf %d 0x$(echo $bytes | cut -d " " -f $(( $byte+2 )),$(( $byte+3 )) | sed 's/ //g'))
	printf "\033[33;1m$aux bytes\n\033[m"

	echo -n "ID: "
	id=$(echo $bytes | cut -d " " -f $(( $byte+4 )),$(( $byte+5 )) | sed 's/ //g')
	aux=$(printf "%d\n" 0x$id)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Flag: "
	flag=$(echo $bytes | cut -d " " -f $(( $byte+6 )) | cut -c1)
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
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+6 )),$(( $byte+7 )) | sed 's/ //g' | cut -c2,3,4))
	printf "\033[33;1m$aux\n\033[m"


	echo -n "TTL: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+8 ))))
	printf "\033[33;1m$aux\n\033[m"

	#DEFINE O PROTOCOLO PARA SER UTILIZADO NA DESCRICAO DA CAMADA 4
	echo -n "Protocolo: "
	proto=$(echo $bytes | cut -d " " -f $(( $byte+9 )))
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
		printf "\033[33;1mProcure o protocolo $proto em /etc/protocols\n\033[m"
	fi

	echo -n "Src IP: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+12 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+13 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+14 )))  0x$(echo $bytes | cut -d " " -f 30))
	printf "\033[33;1m$aux\n\033[m"
    
	echo -n "Dst IP: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+16 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+17 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+18 )))  0x$(echo $bytes | cut -d " " -f $(( $byte+19 ))))
	printf "\033[33;1m$aux\n\033[m"

	#DESLOCA O PONTEIRO DE BYTES PARA A POSICAO IMEDIATAMENTE POSTERIOR AO CABECALHO IP
	byte=$(( $byte + $ipheader ))
	echo
#=======================================ARP=======================================
elif [ "$proto" = "0806" ] || [ "$proto" =  "ARP" ]
then
	echo -n "EhterType: "
    printf "\033[33;1mARP\n\033[m"

	echo
	printf "\033[32;1m=============ARP=============\n\033[m"

	echo -n "Hardware Type: "
	aux=$(echo $bytes | cut -d " " -f $byte,$(( $byte+1 )) | sed 's/ //g')
	if [ $aux = "0001" ]
	then
		printf "\033[33;1mEthernet\n\033[m"
	else
		printf "\033[33;1mVerifique em https://www.iana.org/assignments/arp-parameters/arp-parameters.xhtml o tipo de hardware número $aux\n\033[m"
	fi

	echo -n "Protocol Type: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+2 )),$(( $byte+3 )) | sed 's/ //g')
	if [ $aux = "0800" ]
	then
		printf "\033[33;1mIPv4\n\033[m"
	else
		printf "\033[33;1mVerifique em https://www.wikiwand.com/en/EtherType o tipo de protocolo número $aux\n\033[m"
	fi

	echo -n "Hardware Address Length: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+4 )))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Protocol Address Length: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+5 )))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Op Code: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+6 )),$(( $byte+7 )) | sed 's/ //g')
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
	aux=$(echo $bytes | cut -d " " -f $(( $byte+8 ))-$(( $byte+13 )))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Sender Protocol Adress: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+14 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+15 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+16 )))  0x$(echo $bytes | cut -d " " -f $(( $byte+17 ))))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Target MAC Address: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+18 ))-$(( $byte+23 )))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Target Protocol Adress: "
	aux=$(printf "%d.%d.%d.%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+24 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+25 ))) 0x$(echo $bytes | cut -d " " -f $(( $byte+26 )))  0x$(echo $bytes | cut -d " " -f $(( $byte+27 ))))
	printf "\033[33;1m$aux\n\033[m"

	#LEITURA DO PAYLOAD
	echo
	printf "\033[32;1m==========PAYLOAD============\n\033[m"
	bytes=$(echo $bytes | cut -d " " -f $(( $byte+28 ))-)
	for b in $bytes
	do
	        printf "\033[33;1m\x$b\033[m"
	        sleep 0.005
	done
fi

#====================================CAMADA 4====================================
#======================================TCP=======================================
if [ $proto = "TCP" ]
then
	printf "\033[32;1m===========T C P=============\n\033[m"

	echo -n "Src port: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $byte,$(( $byte+1 )) | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Dst port: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+2 )),$(( $byte+3 )) | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Seq number: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+4 ))-$(( $byte+7 )) | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Ack number: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+8 ))-$(( $byte+11 )) | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Tamanho do cabeçalho TCP: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+12 )) | cut -c1)
	aux=$(printf %d 0x$aux)
	let aux=$aux*4
	tcpheader=$aux
	printf "\033[33;1m$aux bytes\n\033[m"

	echo "Flags: U A P R S F"
	echo "       R C S S Y I"
	echo "       G K H T N N"
	aux=$(echo $bytes | cut -d " " -f $(( $byte+12 )),$(( $byte+13 )) | cut -c2-5 | sed 's/ //g')
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
	bytes=$(echo $bytes | cut -d " " -f $(( $byte+$tcpheader ))-)
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
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $byte,$(( $byte+1 )) | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Dst port: "
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+2 )),$(( $byte+3 )) | sed 's/ //g'))
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Tamanho do cabeçalho UDP: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+4 )),$(( $byte+5 )) | sed 's/ //g')
	aux=$(printf %d 0x$aux)
	udpheader=$aux
	printf "\033[33;1m$aux bytes\n\033[m"

	#LEITURA DO PAYLOAD
	echo
	printf "\033[32;1m==========PAYLOAD============\n\033[m"
	bytes=$(echo $bytes | cut -d " " -f $(( $byte+8 ))-)
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
	aux=$(echo $bytes | cut -d " " -f $byte)
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
	aux=$(printf "%d\n" 0x$(echo $bytes | cut -d " " -f $(( $byte+1 ))))
	printf "\033[33;1m$aux - Verifique em https://pt.wikipedia.org/wiki/Internet_Control_Message_Protocol\n\033[m"

	echo -n "ID BE: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+4 )),$(( $byte+5 )) | sed 's/ //g')
	aux=$(printf %d 0x$aux)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "ID LE: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+5 )))
	aux=$aux$(echo $bytes | cut -d " " -f $(( $byte+4 )))
	aux=$(printf %d 0x$aux)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Seq number BE: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+6 )),$(( $byte+7 )) | sed 's/ //g')
	aux=$(printf %d 0x$aux)
	printf "\033[33;1m$aux\n\033[m"

	echo -n "Seq number LE: "
	aux=$(echo $bytes | cut -d " " -f $(( $byte+7 )))
	aux=$aux$(echo $bytes | cut -d " " -f $(( $byte+6 )))
	aux=$(printf %d 0x$aux)
	printf "\033[33;1m$aux\n\033[m"
	
	#LEITURA DO PAYLOAD
	echo
	printf "\033[32;1m==========PAYLOAD============\n\033[m"
	bytes=$(echo $bytes | cut -d " " -f $(( $byte+7 ))-)
	for b in $bytes
	do
			printf "\033[33;1m\x$b\033[m"
			sleep 0.005
	done
else
	printf "\033[31;1m\nESTE SCRIPT SUPORTA APENAS IPv4 e ARP!\n\033[m"
    printf "\033[33;1mVERIFIQUE OS PARÂMETROS!\n\033[m"
    divisao
	exit 1
fi
echo
divisao
exit 0
