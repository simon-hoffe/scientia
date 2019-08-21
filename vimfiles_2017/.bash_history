exit
for (( i=0; i<5; i++)) do
for (( i=0; i<5; i++)) ; do
versino
version
help
help for
help ((
help let
help
help while
help repeat
help do
help while
cwd
pwd
exit
version
exit
ARR=(a b c d)
exit
exit
if [[ 1=1 ]] ; then echo true ; fi
if [ 1=1 ] ; then echo true ; fi
exit
let odd=1
if [ $odd ] ; then echo true ; else echo false ; fi
let odd=0
if [ $odd ] ; then echo true ; else echo false ; fi
if [ $odd=1 ] ; then echo true ; else echo false ; fi
if [ "$odd=1" ] ; then echo true ; else echo false ; fi
if [ "$odd"="1" ] ; then echo true ; else echo false ; fi
if [ "$odd"="1" ] ; then echo true $odd ; else echo false $odd ; fi
if [ "$odd"=="1" ] ; then echo true $odd ; else echo false $odd ; fi
if ( "$odd"=="1" ) ; then echo true $odd ; else echo false $odd ; fi
if [ "$odd==1" ] ; then echo true $odd ; else echo false $odd ; fi
help [
help test
if [ "$odd==1" ] ; then echo true $odd ; else echoexit false $odd ; fi
exit
exit
exit
ls in/*.pdf
for fn in in/*.pdf ; do echo $fn ; done
for fn in "in/*.pdf" ; do echo $fn ; done
for fn in "in\*.pdf" ; do echo $fn ; done
for fn in "in\\*.pdf" ; do echo $fn ; done
echo in/*.pdf
for fn in "in\*" ; do echo $fn ; done
for fn in "in/*" ; do echo $fn ; done
for fn in "./in/*" ; do echo $fn ; done
. run.sh
ver
version
help
. run.sh
ls in/*.pdf
ls --help
ls -Q in/*.pdf
for fn in $(ls -Q in/*.pdf) ; do echo $fn ; done
IFS=<newline>
IFS="<newline>"
for fn in $(ls -Q in/*.pdf) ; do echo $fn ; done
for fn in $(ls in/*.pdf) ; do echo $fn ; done
ls in/*.pdf
IFS="\r"
for fn in $(ls in/*.pdf) ; do echo $fn ; done
IFS="\n"
for fn in $(ls in/*.pdf) ; do echo $fn ; done
help IFS
help
help :
IFS=$'\n'
for fn in $(ls in/*.pdf) ; do echo $fn ; done
echo $IFS
IFS="."
echo $IFS
IFS='
'
for fn in $(ls in/*.pdf) ; do echo $fn ; done
test=$'\n'
echo "a${test}a"
test=$(echo -en '\n
'
)
test=$(echo -en '\n')
echo "a${test}a"
test=$(echo -en '\na')
echo "a${test}a"
test2=${test:0:1}
test2=${test:1:1}
help
exir
exit
test=$(echo -en '\na')
echo $test
echo a$test
test=$(echo -en "\na")
echo a$test
echo "a${test}a"
echo "a${test#a}a"
echo "a${test##a}a"
echo "a${test%a}a"
. run.sh
. run.sh
sed
. run.sh
. run.sh
temp="ksdks jsdkj skdj kdsjksdj .pdf"
echo "$temp" | bin/sed -e "s/.[pP][dD][fF]//g"
temp2=$(echo "$temp" | bin/sed -e "s/.[pP][dD][fF]//g")
echo $temp2
. run.sh
. run.sh
. run.sh
. run.sh
. run.sh
cd in
exit
help red
help read
quit
exit
read INFO
read -r INFO
echo $INFO
cat run.bat
cat run.bat | read INFO
read INFO < run.bat
echo $INFO
read INFO < $(echo run.bat)
echo $INFO
unset INFO
echo $INFO
read INFO < $(echo run.bat)
echo $INFO
. run.sh
read INFO < $(cat run.bat)
. run.sh
. run.sh
. run.sh
. run.sh
. run.sh
. run.sh
. run.sh
help
help shift
help read
help echo
help split
help
. run.sh
help
. run.sh
. run.sh
. run.sh
stat
exit
bin/stat -c '%y' run.bat 
bin/stat -c '%y' run.bat | bin/date -R
bin/stat -c '%y' run.bat | bin/date -R
bin/stat -c '%y' run.bat | bin/date -d -R
bin/stat -c '%y' run.bat | bin/date -d -R
bin/ls run.bat
bin/ls -l run.bat
bin/stat -c '%y' run.bat | bin/date -R -d --
bin/stat -c '%y' run.bat | bin/date -R -d -
temp=$(echo -en "\na")
NL=${temp%a}
unset temp
OLDIFS="$IFS"
IFS=$NL
let N=1
bfor FN in $(ls *.pdf) ; do c:\apps\pdf2doc\bin\mutool info "$FN" > "$FN.txt"
mkdir txt
for FN in $(ls *.pdf) ; do c:\apps\pdf2doc\bin\mutool info "$FN" > "txt/$FN.txt" ; done
for FN in $(ls *.pdf) ; do /apps/pdf2doc/bin/mutool info "$FN" > "txt/$FN.txt" ; done
exit
help [
help test
help
type delete
type del
exit
convert --help
identify --help
cd out
exit
let x=0001
echo $x
exit
help let
let x=0009
let x=10#0009
run
exit
help
test=$'\n'
echo "a${test}a"
test=$"\n"
echo "a${test}a"
help
exit
dir
ls
exit
help
pwd
exit
XSIZE=2000
let XPT=$XSIZE*720/200/10
echo $XPT
exit
bin/ls -1 in/*.pdf
bin/ls -1 in/*.[pP][dD][fF]
exit
bin/find . -iname "in/*.pdf"
bin/find . -iname 'in/*.pdf'
bin/find . -iname 'in\*.pdf'
bin/find . -iname 'in\\*.pdf'
ls in
ls
ls out
ls out-1
bin/find out -iname '*.png'
bin/find out -iname '.png'
bin/find out/ -iname ".png"
bin/find out-1 -iname ".png"
bin/find out-1 -iname "*.png"
bin/find out-1 -iname '*.png'
exit
bin/ls -1 in/*.pdf
bin/find in -iname '*.pdf'
bin/find --help
bin/find in -iname '*.pdf' -ls
exit
version
help
help
echo %PATH
echo $PATH
dir
ls
ls -l
exit
ls
cd /MinGW
cd /
ls
vim msys.bat
cd /
ls
ls va
ls var
ls bin
exit
exit
echo $PATH
exit
exit
type $0
type 
0=test
exit
pwd
cwd
pwd
echo $0
cd /
ls
mount
ls share
ls $0
exi
exit
mount
ls
cd /
ls
cd c
ls
ls
echo $PATH
cd /c/apps/
cd scannote/
ls
. textcleaner.sh 
cd /c/apps/scannote/
ls
echo $PATH
exit
help read
read NAME < in/name.txt
echo $NAME
echo testtest > in/name.txt
read NAME < in/name.txt
echo $NAME
exit
ver
version
help
test=onetwothre
echo ${test//one/two}
echo ${test/one/two}
exit
test=onetwothree
echo ${test/one/two}
ls
cd /
ls
cd /f
ls
./process2.sh 
./process2.sh < ForwardTrafficLog-disk-2016-11-24T10_34_15.299097__.log > ForwardTrafficLog-disk-2016-11-24T10_34_15.299097.log.csv 
exit
pwd
cd /users/simon.hoffe/00-AMM
cd /c/users/simon.hoffe/00-AMM
cd 00-WIP/227\ UEC\ SSL\ Certificates/
ls
cd Certificates
ls
openssl --help
ssl --help
echo %PATH%
echo $PATH
/c/MinGW/msys/1.0/bin/openssl.exe --help
ls
/c/MinGW/msys/1.0/bin/openssl.exe rsa -in exp2018-10-21__uec_co_za__key_w_pass.pem -out exp2018-10-21__uec_co_za__key.pem
exit
