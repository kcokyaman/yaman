#!/bin/bash
dosyalar="/copytest/dosyalar"
#kaynak = "/home/kursad/kaynak"
hedef="/copytest/hedef/"
#cd $kaynak
while read f
do
   if [[ $f != *".md5"* ]]; then
     if grep -q `csum $f` "$f.md5"
     then
       # md5 OK... Dosya degismemistir
       echo "[$(date +"%T")] $f dosyasinda degisiklik yapilmadigindan kopyalanmamistir."
     else
       # md5 notOK... Dosya degismistir.
       cp -f "$f" $hedef
       echo "[$(date +"%T")] $f dosyasi kopyalanmistir."
       csum "$f">"$f.md5"
     fi
   fi
done < $dosyalar
