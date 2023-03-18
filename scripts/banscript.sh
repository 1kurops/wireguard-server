#!/bin/bash
#Скрипт вписывающий клиентов в банлист в стучае превышения суммы
#входящего и исходящего трафика, на основе данных clients_trafic.sh
ban_list="etc/wireguard/banlist.txt"
ban_tmp1="/opt/wireguard_server/scripts/ban_tmp1.txt"
ban_tmp2="/opt/wireguard_server/scripts/ban_tmp2.txt"

  if [[ ! -f "${ban_tmp1}" ]]; then
    touch /opt/wireguard_server/scripts/ban_tmp1.txt
  fi
  if [[ ! -f "${ban_tmp2}" ]]; then
    touch /opt/wireguard_server/scripts/ban_tmp2.txt
  fi

  if [[ ! -f "${ban_list}" ]]; then
    touch etc/wireguard/banlist.txt
  fi

  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number of gigabytes>"
    exit 1
  fi

  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: argument must be a positive integer."
    exit 1
  fi
limit_gb="$1"
limit_bytes=$(( gb * 1024 * 1024 * 1024 ))


exec /etc/wireguard/clients_trafic.sh -b | echo "$(awk '$3 > $(limit_bytes) { print $1 }')" > $ban_tmp1
exec /etc/wireguard/clients_trafic.sh -b | echo "$(awk '$4 > $(limit_bytes) { print $1 }')" >> $ban_tmp1
sort -u $ban_tmp1 > $ban_tmp2
cat $ban_tmp1 > $ban_list
rm $ban_tmp1 $ban_tmp2