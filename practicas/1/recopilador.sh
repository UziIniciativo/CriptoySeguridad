#!/bin/bash

is_ip(){
    local ip=$1
    [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}

is_domain(){
    local domain=$1
    [[ $domain =~ ^[a-zA-Z0-9.-]+$ ]]
}

# Verificamos que haya entrada
if [ -z "$1" ]; then
    echo "Por favor, proporciona una IP o un nombre de dominio."
    exit 1
fi

#Catalogamos la entrada


if is_ip "$1"; then
    IP="$1"
    DOMAIN=$(nslookup "$1" | grep -E 'name = ' | sed 's/.*name = //')
elif is_domain "$1"; then
    DOMAIN="$1"
    IP=$(nslookup "$1" | grep -E 'Address: ' | sed 's/Address: //' | head -n 1)
else
    echo "$1 no es ni una dirección IP ni un nombre de dominio válido."
    exit 1
fi

# Guardamos fecha
WHOIS_DOM=$(whois "$DOMAIN")
CREATED=$(echo "$WHOIS_DOM" | grep -E 'Creat' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)
UPDATED=$(echo "$WHOIS_DOM" | grep -E 'Updat' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)
EXPIRED=$(echo "$WHOIS_DOM" | grep -E 'Expiration Date: ' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)

# Guardamos Datos de la organizacion

WHOIS_IP=$(whois "$IP")

OWNER=$(echo "$WHOIS_IP" | grep -iE 'owner:|orgname:' | sed 's/\(owner\|OrgName\):\s*//')
COUNTRY=$(echo "$WHOIS_IP" | grep -iE 'country:' | sed 's/[cC]ountry: \s*//')
STATE=$(echo "$WHOIS_IP" | grep -iE 'stateprov:' | sed 's/StateProv: \s*//')
CITY=$(echo "$WHOIS_IP" | grep -iE 'city:' | sed 's/City: \s*//')
ADDRESS=$(echo "$WHOIS_IP" | grep -iE 'address:' | sed 's/[aA]ddress: \s*//')
POSTALCODE=$(echo "$WHOIS_IP" | grep -iE 'postalcode' | sed 's/PostalCode: \s*//')
PERSONAL=$(echo "$WHOIS_IP" | grep -iE 'responsible:|person:|OrgTechName:' | sed 's/\(responsible\|OrgTechName\|person\):\s*//')
EMAIL=$(echo "$WHOIS_IP" | grep -iE 'e-mail:|orgtechemail:' | sed 's/\(e-mail\|OrgTechEmail\):\s*//')
PHONE=$(echo "$WHOIS_IP" | grep -iE 'phone:' | sed 's/phone:\s*/TrabajadorPhone:/')

# Comprobar conectividad
PING=$(ping "$IP" -c 4| tail -n 2)
CHECKCON=$(echo "$PING" |head -n 1| sed  's/packets transmitted/paquetes transmitidos/'| sed  's/received/recibidos/' | sed  's/packet loss/paquetes perdidos/' | sed  's/time/tiempo/')
LATENCY=$(echo "$PING" | tail -n 1 | sed 's/.*=\s*\([0-9\.]*\)\/\([0-9\.]*\)\/.*/\2/')
SEGMENT=$(echo "$WHOIS_IP" | grep -iE "inetnum|NetRange|CIDR")
IPV6=$(digo +short AAAA "$DOMAIN" | head -n 1)
REVERSE=$(dig -x "$IP" |  grep PTR | grep -oP '\b(?:\d{1,3}\.){3}\d{1,3}\b')
TRACEROUTE=$(tracerout "$IP")
SUBDOMAINS=$(dnsmap "$IP" | tail -n +5 | head -n -3)
DNS=$(dnsrecon -d "$DOMAIN" -t std |grep -E '\bA\b|\bAAAA\b|\bPTR\b|\bMX\b|\bNS\b|\bTXT\b|\bCNAME\b|\bSOA\b' | sed 's/\[\*\]\s*//g')

#Nmap
NMAP=$(nmap -O -n -sV "$IP"| sed -E 's/Device type\s*/Tipo de Dispositivo/g; s/Running\s*/Ejecutando/g; s/JUST GUESSING\s*/Aproximadamente/g; s/Aggressive OS guesses\s*/Aproximacion agresiva de Sistema Operativo/g; s/OS details\s*/Detalles del Sistema Operativo/g; s/OS \s*/Sistema Operativo /g')

# Formateamos la salida
OUTPUT="### Información sobre la dirección o dominio ###\n"
OUTPUT+="\nDirección IP: $IP\n"
OUTPUT+="Dominio: $DOMAIN\n"
OUTPUT+="\n### Información WHOIS del Dominio ###\n"
OUTPUT+="Fecha de Creación: $CREATED\n"
OUTPUT+="Fecha de Actualización: $UPDATED\n"
OUTPUT+="Fecha de Expiración: $EXPIRED\n"
OUTPUT+="\n### Información WHOIS de la IP ###\n"
OUTPUT+="Propietario: $OWNER\n"
OUTPUT+="País: $COUNTRY\n"
OUTPUT+="Estado: $STATE\n"
OUTPUT+="Ciudad: $CITY\n"
OUTPUT+="Dirección: $ADDRESS\n"
OUTPUT+="Código Postal: $POSTALCODE\n"
OUTPUT+="Persona Responsable: $PERSONAL\n"
OUTPUT+="Correo Electrónico: $EMAIL\n"
OUTPUT+="Teléfono: $PHONE\n"
OUTPUT+="\n### Conectividad ###\n"
OUTPUT+="Conectividad (ping): $CHECKCON\n"
OUTPUT+="Latencia: $LATENCY ms\n"
OUTPUT+="\n### Información Adicional ###\n"
OUTPUT+="Segmento de Red: $SEGMENT\n"
OUTPUT+="Dirección IPv4: $IPV4\n"
OUTPUT+="Dirección IPv6: $IPV6\n"
OUTPUT+="Reverse DNS: $REVERSE\n"
OUTPUT+="Ruta de Traceroute: $TRACEROUTE\n"
OUTPUT+="Subdominios: $SUBDOMAINS\n"
OUTPUT+="DNS: $DNS\n"
OUTPUT+="\n### Resultados de Nmap ###\n"
OUTPUT+="$NMAP\n"

# Guardar en un archivo
echo -e "$OUTPUT" | tee resultado.txt

# Imprimir en la terminal
echo -e "$OUTPUT"
