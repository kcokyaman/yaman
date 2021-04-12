#!/bin/bash
# 16 haneli sifre tanimi
USERPASS=`dd if=/dev/urandom bs=16 count=1 2>/dev/null | openssl base64 | sed "s/[=O/\]//g" | cut -b1-16`
# Sifre degistir 
echo "root":$USERPASS|chpasswd
# tekrar loginde sifre degisikligi isteme
pwdadm -c root
# unsuccessful login 'leri sifirla
chsec -f /etc/security/lastlog -s root -a unsuccessful_login_count=0
# mail gonder
/admin/mgonder.sh aix_snc@kursadcokyaman.com kursad@kursadcokyaman.com "`hostname` root/wbsphere/armadm AIX Password" $USERPASS
