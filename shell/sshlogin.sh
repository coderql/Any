#!/bin/bash
# this script is used to auto ssh login a remote system.

ip=
username=
password=
case $1 in
  "servername")
  eval sshpass -p $ip ssh $username@$ip
  ;;
  * )
  echo "Unknown host alias."
esac
