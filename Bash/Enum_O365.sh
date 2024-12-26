#!/bin/bash

# List of usernames to loop through
usernames=(
  "firstName.LastName@domain.net"
  "firstName.LastName@domain.net"
)

# Loop through each username
for username in "${usernames[@]}"; do
  # Send the POST request and store the response
  response=$(curl -s -X POST 'https://login.microsoftonline.com/common/GetCredentialType?mkt=en-US' \
    -H 'Host: login.microsoftonline.com' \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0' \
    -H 'Accept: application/json' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'Origin: https://login.microsoftonline.com' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Priority: u=0' \
    -H 'Te: trailers' \
    --data-raw '{"username":"'"$username"'","isOtherIdpSupported":false,"checkPhones":true,"isRemoteNGCSupported":true,"isCookieBannerShown":false,"isFidoSupported":true,"isAccessPassSupported":true,"isQrCodePinSupported":true}')
  
  # Check if the response contains "CertAuthParams":null
  if [[ "$response" == *'"CertAuthParams":null'* ]]; then
    echo "The username $username is not found."
  else
    echo "The username $username is found."
  fi
done
