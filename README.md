
Script simples para análise de bytes para cabeçalhos IP e TCP/UDP, ICMP e também pacotes ARP.

V1:
Sintaxe de uso:

./bytes.sh <"seq_bytes">

./bytes.sh <arquivo_com_bytes>



Exemplos:

./bytes.sh "1c 4b d6 66 e1 c0 46 a7 cf c3 8c 0a 08 00 45 00 00 3c 00 00 40 00 2e 06 2c e2 42 93 f0 aa c0 a8 2b f4 08 2f cb 10 49 2f fb 42 8a 2e b2 c7 a0 12 16 a0 a3 fd 00 00 02 04 05 78 04 02 08 0a 55 fe 99 06 00 25 29 e2 01 03 03 07"

./bytes.sh "ff ff ff ff ff ff 0a 00 27 00 00 00 08 06 00 01 08 00 06 04 00 03 0a 00 27 00 00 00 c0 a8 38 01 00 00 00 00 00 00 c0 a8 38 66"

./bytes.sh sequencia.txt



V2:
Sintaxe de uso:

./bytes_v2.sh -b seq_bytes_ou_arquivo [opcões]
Opcões:
	-h		        Ajuda e modo de uso
	-p protocolo	Protocolo mais baixo a ser analizado (Ethernet por padrão) [opcional]
	   ip
	   arp
	   tcp
	   udp
	   icmp


Exemplos:

./bytes_v2.sh -b "1c 4b d6 66 e1 c0 46 a7 cf c3 8c 0a 08 00 45 00 00 3c 00 00 40 00 2e 06 2c e2 42 93 f0 aa c0 a8 2b f4 08 2f cb 10 49 2f fb 42 8a 2e b2 c7 a0 12 16 a0 a3 fd 00 00 02 04 05 78 04 02 08 0a 55 fe 99 06 00 25 29 e2 01 03 03 07"

./bytes_v2.sh -b "ff ff ff ff ff ff 0a 00 27 00 00 00 08 06 00 01 08 00 06 04 00 03 0a 00 27 00 00 00 c0 a8 38 01 00 00 00 00 00 00 c0 a8 38 66"

/bytes_v2.sh -b "45 00 00 4c d1 b4 00 00 40 01 4e a3 ac 10 01 37 ac 10 01 02 08 00 dc 3a 83 08 00 00 64 73 74 20 68 74 74 70 20 70 6f 72 74 20 38 30 20 2f 6d 61 6c 77 61 72 65 2e 74 78 74 20 2d 20 4b 45 59 3a 20 30 30 32 39 38 34 31 37 31 37 32" -p ip

./bytes_v2.sh -b sequencia.txt
