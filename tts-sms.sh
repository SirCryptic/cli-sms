#!/bin/bash

# Developer: SirCryptic (NullSecurityTeam)
# Info: sms script v1.0 {BETA}
# Disclaimer: DO NOT USE THIS TO TROLL OR SPAM PEOPLE I WILL NOT BE RESPONSIBLE FOR YOUR USAGE!

# Details: Get a API key from here: https://www.clicksend.com

# Set the ClickSend API credentials
api_username="scns1337"
api_key="AEDCE6CF-AB1B-08B9-FE99-B3AE0B166B72"

# Set the API endpoint and headers
url="https://rest.clicksend.com/v3/voice/send"
headers=(
  "Authorization: Basic $(echo -n "$api_username:$api_key" | base64)"
  "Content-Type: application/json"
)

# Set the name of the phone book file
phone_book_file="phonebook.txt"

# Define an associative array to store phone numbers and their associated names
declare -A phone_book

# Load phone numbers from the phone book file
if [[ -f "$phone_book_file" ]]; then
  while IFS= read -r line; do
    number=$(echo "$line" | cut -d' ' -f1)
    name=$(echo "$line" | cut -d' ' -f2-)
    phone_book[$number]=$name
  done < "$phone_book_file"
fi

# Function to add a phone number to the phone book
function add_number {
  echo "Enter the phone number:"
  read number
  echo "Enter a name for the recipient:"
  read name
  phone_book[$number]=$name
  echo "Added $name ($number) to the phone book."
  echo "$number,$name" >> "$phone_book_file"
}

# Prompt the user to select a country
echo "Select a country code:"
select country_code in "US" "AU" "GB"
do
  if [[ -n $country_code ]]; then
    break
  fi
done

# Prompt the user to enter a message
echo "Enter a message:"
read message

# Prompt the user to select a recipient or add a new one
echo "Select an option:"
select option in "Select a recipient" "Add a new recipient"
do
  case $option in
    "Select a recipient")
      # Prompt the user to select a recipient from the phone book
      echo "Select a recipient:"
      select number in "${!phone_book[@]}"
      do
        if [[ -n $number ]]; then
          recipient_name=${phone_book[$number]}
          break
        fi
      done
      break
      ;;
    "Add a new recipient")
      # Call the add_number function to add a new number to the phone book
      add_number
      # Prompt the user to select the newly added recipient
      echo "Select the newly added recipient:"
      select number in "${!phone_book[@]}"
      do
        if [[ -n $number ]]; then
          recipient_name=${phone_book[$number]}
          break
        fi
      done
      break
      ;;
  esac
done

# Prompt the user to select whether to schedule the message or send it immediately
echo "Do you want to schedule the message? (y/n)"
read schedule

if [[ $schedule == "y" ]]; then
  # Prompt the user to enter the schedule date and time
  echo "Enter the schedule date and time in the format \"YYYY-MM-DD HH:MM:SS\" (e.g. 2023-02-24 10:00:00):"
  read schedule_time
  schedule_time=$(date -d "$schedule_time" '+%s')
recipient_name="{
    \"messages\": [
        {
            \"source\": \"bash\",
            \"body\": \"$message\",
            \"to\": \"$number\",
            \"schedule\": $schedule_time
        }
    ]
}"
else
recipient_name="{
    \"messages\": [
        {
            \"source\": \"bash\",
            \"body\": \"$message\",
            \"to\": \"${number//,}\"
        }
    ]
}"
fi

# Send the API request
response=$(curl --silent --show-error --request POST --url $url --header "${headers[0]}" --header "${headers[1]}" --data-binary "$recipient_name")

# Print the API response
echo "$response" | jq
