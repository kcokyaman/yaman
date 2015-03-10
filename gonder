#!/bin/bash

(
sleep 1
echo "HELO atos.net.tr"
sleep 1
echo "Mail From: $1"
sleep 1
echo "Rcpt To: $2"
sleep 1
echo "Data"
sleep 1
echo "From: LNX_Security_Update
Subject: $3
"
cat $4
echo "
."
sleep 1
echo "quit"
)|telnet 212.133.133.21 25
