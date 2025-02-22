#!/bin/bash

dos2unix remote_lists.txt
readarray -t BLOCKLIST_DOWNLOADS < remote_lists.txt

BL_FILE="/tmp/ip-blocklist.txt"
BL_TMP_FILE="/tmp/ip-blocklist.txt.tmp"

rm -f $BL_FILE
touch $BL_FILE

echo "Downloading blocklists..."
for to_download in "${BLOCKLIST_DOWNLOADS[@]}"
do
    echo "Downloading blocklist from $to_download and appending to $BL_FILE"
    wget -qO --timeout=30 - $to_download >> $BL_FILE || echo "[WARN] Failed to download $to_download" && true
done
echo "Finished downloading"

echo "Importing local blocklist from local.txt and appending to $BL_FILE"
dos2unix local.txt
cat local.txt >> $BL_FILE

sed -i -e '$a\' $BL_FILE

rm -f $BL_TMP_FILE
echo "Filtering out single IPv6 addresses and converting to network"
grep -E -o "(^[0-9a-fA-F:]*$)" $BL_FILE | sed 's/$/\/128/' >> $BL_TMP_FILE

echo "Filtering out IPv6 networks"
grep -E -o "(^[0-9a-fA-F:]*\/[0-9]{1,3}$)" $BL_FILE >> $BL_TMP_FILE

echo "Removing duplicates from the list..."
sort -u $BL_TMP_FILE -o $BL_FILE

rm -f $BL_TMP_FILE
(cat $BL_FILE | aggregate6 -6) > $BL_TMP_FILE

rm -f $BL_FILE
echo "Filtering out IPv6 networks"
(grep -E -o "(^[0-9a-fA-F:]*\/[0-9]{1,3}$)" $BL_TMP_FILE | sort) >> $BL_FILE

if grep -q "/0" $BL_FILE; then 
    echo "CANNOT BLOCK ALL TRAFFIC!"
    exit 1
fi

cat $BL_FILE > $OUT_FILE
