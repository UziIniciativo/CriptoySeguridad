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

echo -e "<======================================== DIRECCIONES Y DOMINIOS ========================================>\n"| tee -a "$DOMAIN".txt
echo -e "\nDirección IP: $IP\n" | tee "$DOMAIN".txt
echo -e "Dominio: $DOMAIN\n" | tee "$DOMAIN".txt

echo -e "\n<======================================== FECHAS IMPORTANTES ========================================>\n" | tee -a "$DOMAIN".txt

WHOIS_DOM=$(whois "$DOMAIN")

echo -e "Fecha de Creación: $(echo "$WHOIS_DOM" | grep -E 'Creat' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)\n" | tee -a "$DOMAIN".txt
echo -e "Fecha de Actualización:  $(echo "$WHOIS_DOM" | grep -E 'Updat' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)\n" | tee -a "$DOMAIN".txt
echo -e "Fecha de Expiración: $(echo "$WHOIS_DOM" | grep -E 'Expiration Date: ' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)\n" | tee -a "$DOMAIN".txt

WHOIS_IP=$(whois "$IP")

echo -e "Organización Propietaria: $(echo "$WHOIS_IP" | grep -iE 'owner:|orgname:' | sed 's/\(owner\|OrgName\):\s*//')\n" | tee -a "$DOMAIN".txt


echo -e "Países asociados: $(echo "$WHOIS_IP" | grep -iE 'country:' | sed 's/[cC]ountry: \s*//')\n" | tee -a "$DOMAIN".txt
echo -e "Estados asociados: $(echo "$WHOIS_IP" | grep -iE 'stateprov:' | sed 's/StateProv: \s*//')\n" | tee -a "$DOMAIN".txt
echo -e "Ciudades asociadas: $(echo "$WHOIS_IP" | grep -iE 'city:' | sed 's/City: \s*//')\n" | tee -a "$DOMAIN".txt
echo -e "Direcciones asociadas: $(echo "$WHOIS_IP" | grep -iE 'address:' | sed 's/[aA]ddress: \s*//')\n" | tee -a "$DOMAIN".txt
echo -e "Código Postal: $(echo "$WHOIS_IP" | grep -iE 'postalcode' | sed 's/PostalCode: \s*//')\n" | tee -a "$DOMAIN".txt
echo -e "Personal: $(echo "$WHOIS_IP" | grep -iE 'responsible:|person:|OrgTechName:' | sed 's/\(responsible\|OrgTechName\|person\):\s*//')\n" | tee -a "$DOMAIN".txt
echo -e "Correos del Personal: $(echo "$WHOIS_IP" | grep -iE 'e-mail:|orgtechemail:' | sed 's/\(e-mail\|OrgTechEmail\):\s*//')\n" | tee -a "$DOMAIN".txt
echo -e "Teléfonos del Personal: $(echo "$WHOIS_IP" | grep -iE 'phone:' | sed 's/phone:\s*/TrabajadorPhone:/')" | tee -a $DOMAIN".txt
\n"
echo -e "\n<======================================== CONECTIVIDAD ========================================>\n" | tee -a "$DOMAIN".txt
echo -e "Conectividad (ping): $(ping "$IP" -c 4| tail -n 2)\n" | tee -a "$DOMAIN".txt
echo -e "Latencia: $(echo "$PING" | tail -n 1 | sed 's/.*=\s*\([0-9\.]*\)\/\([0-9\.]*\)\/.*/\2/') ms\n" | tee -a "$DOMAIN".txt

echo -e "\n<======================================== INFORMACION DE RED Y DNS ========================================>\n" | tee -a "$DOMAIN".txt
echo -e "Segmento de Red: $(echo "$WHOIS_IP" | grep -iE "inetnum|NetRange|CIDR")\n" | tee -a "$DOMAIN".txt
echo -e "Dirección IPv4: $IP\n" | tee -a "$DOMAIN".txt
echo -e "Dirección IPv6: $(dig +short AAAA "$DOMAIN" | head -n 1)\n" | tee -a "$DOMAIN".txt
echo -e "Reverse DNS: $(dig -x "$IP" |  grep PTR | grep -oP '\b(?:\d{1,3}\.){3}\d{1,3}\b')\n" | tee -a "$DOMAIN".txt
echo -e "Ruta de Traceroute: $(traceroute "$IP")\n" | tee -a "$DOMAIN".txt
echo -e "Subdominios:\n $(dnsmap "$DOMAIN" | tail -n +5 | head -n -3)\n" | tee -a "$DOMAIN".txt
echo -e "DNS: $(dnsrecon -d "$DOMAIN" -t std |grep -E '\bA\b|\bAAAA\b|\bPTR\b|\bMX\b|\bNS\b|\bTXT\b|\bCNAME\b|\bSOA\b' | sed 's/\[\*\]\s*//g')\n" | tee -a "$DOMAIN".txt

echo -e "\n<======================================== INFORMACION DE PUERTOS, SERVICIOS Y SISTEMA OPERATIVO ========================================>\n" | tee -a "$DOMAIN".txt
echo -e "$(nmap -O -n -sV "$IP"| sed -E 's/Device type\s*/Tipo de Dispositivo/g; s/Running\s*/Ejecutando/g; s/JUST GUESSING\s*/Aproximadamente/g; s/Aggressive OS guesses\s*/Aproximacion agresiva de Sistema Operativo/g; s/OS details\s*/Detalles del Sistema Operativo/g; s/OS \s*/Sistema Operativo /g'| grep -E 'PORT|[0-9]+/[a-Z]+|Ejecutando|Sistema Operativo|Tipo de Dispositivo')\n" | tee -a "$DOMAIN".txt
