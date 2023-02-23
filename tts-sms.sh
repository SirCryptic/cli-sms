#!/bin/bash

# Developer: SirCryptic (NullSecurityTeam)
# Info: tts-sms script v1.0 {BETA}
# Disclaimer: DO NOT USE THIS TO TROLL OR SPAM PEOPLE I WILL NOT BE RESPONSIBLE FOR YOUR USAGE!

# Details: Get a API key from here: https://www.clicksend.com

# Set the ClickSend API credentials
api_username="your_username"
api_key="your_api_key"

# Set the API endpoint and headers
url="https://rest.clicksend.com/v3/voice/send"
headers=(
  "Authorization: Basic $(echo -n "$api_username:$api_key" | base64)"
  "Content-Type: application/json"
)

# Prompt the user to enter the message
echo "Enter the message to send:"
read message_body

# Prompt the user to enter the recipient's phone number
echo "Enter the recipient's phone number (including country code, e.g. +1234567890):"
read to_number

# Prompt the user to select whether to schedule the message or send it immediately
echo "Do you want to schedule the message? (y/n)"
read schedule

if [[ $schedule == "y" ]]; then
  # Prompt the user to enter the schedule date and time
  echo "Enter the schedule date and time in the format \"YYYY-MM-DD HH:MM:SS\" (e.g. 2023-02-24 10:00:00):"
  read schedule_time
  schedule_time=$(date -d "$schedule_time" '+%s')
  request_body="{
    \"messages\": [
        {
            \"source\": \"bash\",
            \"body\": \"$message_body\",
            \"to\": \"$to_number\",
            \"schedule\": $schedule_time
        }
    ]
}"
else
  request_body="{
    \"messages\": [
        {
            \"source\": \"bash\",
            \"body\": \"$message_body\",
            \"to\": \"$to_number\"
        }
    ]
}"
fi

# Send the API request
response=$(curl --silent --show-error --request POST --url $url --header "${headers[0]}" --header "${headers[1]}" --data-binary "$request_body")

# Print the API response
echo "$response" | jq
