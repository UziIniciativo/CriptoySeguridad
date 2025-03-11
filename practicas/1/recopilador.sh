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
WHOIS_DOM=$(whois "$DOMINIO")
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
