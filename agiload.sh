#!/bin/bash

. ~/.agiloadrc

die()
{
	echo "ERROR: $1"
	exit 1
}

[ -f $1 ] || die "Missing file to upload"

CURL="curl -c $COOKFILE -b $COOKFILE"
HASH=`$CURL $SERVER/ajaxlogin.php -d "login=$LOGIN&pass=$PASS"`
echo "Logged in with hash: $HASH"
RES=`$CURL $SERVER/upload.php -F "u=@$1;type=application/octet-stream"`
echo "Upload result: '$RES'"
if [ "$RES" == "OK" ]; then
	exit 0
fi

exit 1

