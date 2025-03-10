#!/bin/bash

es_ip(){
    local ip=$1
    [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}

es_dominio(){
    local dominio=$1
    [[ $dominio =~ ^[a-zA-Z0-9.-]+$ ]]
}
# Verificamos que haya entrada
if [ -z "$1" ]; then
    echo "Por favor, proporciona una IP o un nombre de dominio."
    exit 1
fi

#Catalogamos la entrada

if es_ip "$1"; then
    IP="$1"
    DOMINIO=$(nslookup "$1" | grep -E 'name = ' | sed 's/.*name = //')
elif es_dominio "$1"; then
    DOMINIO="$1"
    IP=$(nslookup "$1" | grep -E 'Address: ' | sed 's/Address: //' | head -n 1)
else
    echo "$1 no es ni una dirección IP ni un nombre de dominio válido."
    exit 1
fi

# Guardamos fecha
WHOIS_DOM=$(whois "$DOMINIO")
CREADO=$(echo "$WHOIS_DOM" | grep -E 'Creat' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)
ACTUALIZADO=$(echo "$WHOIS_DOM" | grep -E 'Updat' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)
EXPIRADO=$(echo "$WHOIS_DOM" | grep -E 'Expiration Date: ' | grep -oP '\d{4}-\d{2}-\d{2}' | head -n 1)

# Guardamos Datos de la organizacion

WHOIS_IP=$(whois "$IP")
OWNER=$(echo "$WHOIS_IP" | grep 'owner' | head -n 1 | sed 's/owner: \s*//')

if [[ -n "$OWNER"]]; then
   OWNER=$(echo "$WHOIS_IP" | grep 'OrgName' | head -n 1 | sed 's/OrgName: \s*//')
fi

COUNTRY=$(echo "$WHOIS_IP" | grep -i 'country' | head -n 1 | sed 's/[cC]ountry: \s*//')
