#!/bin/bash
# SPREADSHEETID='[SPREADSHEET_ID]'
# API_KEY='[GOOGLE_SHEETS_API_KEY]'

ACCESS_TOKEN=$(curl --silent --request GET \
		"https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEETID}/values/\
Sheet1!H2?key=$API_KEY" \
		--header 'Accept: application/json' \
		--compressed | tr -d '\n' | sed -En 's/^.*"values":.*\[.*\[.*\"(.+)\".*/\1/p')

response=$(curl --silent --request POST \
	     "https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEETID}/values/\
Sheet1!A1:B1:append?valueInputOption=RAW" \
	     --header "Authorization: Bearer $ACCESS_TOKEN" \
	     --header 'Accept: application/json' \
	     --header 'Content-Type: application/json' \
	     --data "{values: [[\"$(hostname)\", \"$(curl --silent ifconfig.co)\"]]}" \
	     --compressed | tr -d '\n')

if [ ! -z "$(echo $response | grep -E '^{\s*"error"')" ]
then
	echo "Failed to acquire correct Access Token"
	exit 1
fi

coordinates=$(echo $response | sed -En 's/.*\"updatedRange\":.*\"(.+!(([A-Z]([0-9]+)):.+))\",.*/\4/p')
echo "$coordinates"
