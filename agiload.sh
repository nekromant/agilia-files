#!/bin/bash
#usage agiload.sh file1 file2 ...
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
while [ -f $1 ]; do
	echo "Uploading $1"
	RES=`$CURL $SERVER/upload.php -F "u=@$1;type=application/octet-stream"`
	echo "Upload result: '$RES'"
	if [ "$RES" != "OK" ]; then
		exit 1
	fi
	shift
done
exit 0

