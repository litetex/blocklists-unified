#!/bin/bash

current_ip_v4=$(curl -s https://ipv4.icanhazip.com/)
current_ip_v6=$(curl -s https://ipv6.icanhazip.com/)

echo "Current IPv4: $current_ip_v4"
echo "Current IPv6: $current_ip_v6"

dos2unix remote_lists.txt
readarray -t BLOCKLIST_DOWNLOADS < remote_lists.txt

BL_FILE="/tmp/ip-blocklist.txt"
BL_TMP_FILE="/tmp/ip-blocklist.txt.tmp"

rm -f $BL_FILE
touch $BL_FILE

## Keep a "cache" around so that if the remote site is (temporarily) not reachable one can still build the final list
echo "Downloading blocklists..."

BL_DWL_TMP_DIR=/tmp/bl-dwls
rm -rf $BL_DWL_TMP_DIR
mkdir -p $BL_DWL_TMP_DIR

cached_file_names=()
for dwl_url in "${BLOCKLIST_DOWNLOADS[@]}"
do
    file_name=$(echo $dwl_url | sed -r 's@[:/.]+@_@g')
    cached_file_names+=($file_name)
    echo "Downloading blocklist from $dwl_url to $file_name"
    if wget --timeout=10 -qO - $dwl_url > $BL_DWL_TMP_DIR/$file_name; then
        if [ -s $BL_DWL_TMP_DIR/$file_name ]; then
            mv $BL_DWL_TMP_DIR/$file_name /source_cached_remote_lists/$file_name
        else
            echo "[WARN] Empty payload received from $dwl_url - not copying"
        fi
    else
        echo "[WARN] Failed to download $dwl_url"
    fi
done
echo "Finished downloading"

echo "Importing remote lists"
for to_import in /source_cached_remote_lists/*
do
    file_name=$(basename $to_import)
    if [[ ! " ${cached_file_names[*]} " =~ " ${file_name} " ]]; then
        echo "[WARN] Deleting $to_import as it's not on the download list"
        rm -f $to_import
        continue;
    fi
    echo "Importing remote lists $to_import"
    cat "$to_import" >> $BL_FILE
done
echo "Importing remote lists finished"

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
