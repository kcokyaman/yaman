#!/bin/bash
#Bu script ile AIX uzerindeki kullanıcı sifresi degistirilir.
pass=`dd if=/dev/urandom bs=16 count=1 2>/dev/null | openssl base64 | sed "s/[=O/\]//g" | cut -b1-16`
echo "test":$pass|chpasswd
pwdadm -c test
echo "test kullanıcısının şifresi değiştirildi: "$pass>>/tmp/pass.log
