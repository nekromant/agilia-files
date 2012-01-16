#!/bin/bash -x
die()
{
    echo "ERROR: $1"
    exit 1
}

[ -f ~/.agiloadrc ] && . ~/.agiloadrc

: {SERVER:="packages.agilialinux"}
: {COOKFILE:=$(mktemp)}

[ -z "$LOGIN" ] || echo -n "Login: "; read LOGIN
[ -z "$PASS" ] || echo -n "Pass: "; stty -echo; read PASS; echo; stty echo;

CURL="curl -c $COOKFILE -b $COOKFILE"
HASH=$($CURL $SERVER/ajaxlogin.php -d "login=$LOGIN&pass=$PASS") &> /dev/null

for item in $@; do
    echo "Trying to upload $item..."
    [  -f $item ] || die "No such file!"
    RES=$($CURL $SERVER/upload.php -F "u=@$item;type=application/octet-stream")
    echo "Upload result: $RES"
    if [ "$RES" != "OK" ]; then
	rm $COOKFILE
        die "Upload failed!"
        exit 1
    fi
done

rm $COOKFILE
