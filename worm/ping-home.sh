#!/bin/bash
DEFAULT_PING=3
ACCESS_TOKEN=$1
COORDINATE=$2

response=$(curl --silent --request PUT \
	     "https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEETID}/values/\
Sheet1!C${COORDINATE}:F${COORDINATE}?valueInputOption=RAW&includeValuesInResponse=TRUE" \
	     --header "Authorization: Bearer $ACCESS_TOKEN" \
	     --header 'Accept: application/json' \
	     --header 'Content-Type: application/json' \
	     --data "{range:\"Sheet1!C${COORDINATE}:F${COORDINATE}\",\
values: [[null, null, null, \"$(date)\"]]}" \
	     --compressed | tr -d '\n')

refresh_time=$(echo $response | sed -En 's/^.*"values":.*\[.*\[[[:space:]]*\"([0-9]+)\",.*/\1/p')
input=$(echo $response | sed -En 's/^.*"values":.*\[.*\[[[:space:]]*\"([0-9]+)\",[[:space:]]*\"(.+)\",[[:space:]]*\"(.*)\",[[:space:]]*.*/\2/p')

if [ ! -z "$input" ]; then
	input=$(eval $input)
	echo $input
	response=$(curl --request PUT \
	     "https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEETID}/values/\
Sheet1!D${COORDINATE}:E${COORDINATE}?valueInputOption=RAW&includeValuesInResponse=TRUE" \
	     --header "Authorization: Bearer $ACCESS_TOKEN" \
	     --header 'Accept: application/json' \
	     --header 'Content-Type: application/json' \
	     --data "{range:\"Sheet1!D${COORDINATE}:E${COORDINATE}\",values: [[\"\", \"$(echo $input | sed 's/\"/\\\"/g' | sed 's/\n/\\\n/g')\"]]}" \
		--compressed)
fi

if [ -z "$refresh_time" ]; then
	echo "No data in designated row, default to normal ping time"
	exit $DEFAULT_PING
else
	exit $refresh_time
fi


