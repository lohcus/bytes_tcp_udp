Script simples para análise de bytes para cabeçalhos IP e TCP/UDP, ICMP e também pacotes ARP.

Sintaxe de uso:

./bytes.sh <"seq_bytes">

./bytes.sh <arquivo_com_bytes>

Exemplos:
./bytes.sh "1c 4b d6 66 e1 c0 46 a7 cf c3 8c 0a 08 00 45 00 00 3c 00 00 40 00 2e 06 2c e2 42 93 f0 aa c0 a8 2b f4 08 2f cb 10 49 2f fb 42 8a 2e b2 c7 a0 12 16 a0 a3 fd 00 00 02 04 05 78 04 02 08 0a 55 fe 99 06 00 25 29 e2 01 03 03 07"

./bytes.sh "ff ff ff ff ff ff 0a 00 27 00 00 00 08 06 00 01 08 00 06 04 00 03 0a 00 27 00 00 00 c0 a8 38 01 00 00 00 00 00 00 c0 a8 38 66"

./bytes.sh sequencia.txt
