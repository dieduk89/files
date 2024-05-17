#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -c"
SERVICES=$($PSQL "SELECT service_id || ') ' || name as text FROM services")
echo -e "\n~~Salon Appointment~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "Which service do you want?"
  echo "$SERVICES" | while read TEXT
  do
    if [[ $TEXT =~ ^[0-9].*$ ]]
    then
      echo "$TEXT"
    fi
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Service not found."
  else
    SERVICE_QUERY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ $SERVICE_QUERY =~ 0 ]]
    then
      MAIN_MENU "Service not found."
    else
      SERVICE_NAME=$(echo "$SERVICE_QUERY" | sed -n 3p)
      DO_SERVICE $SERVICE_ID_SELECTED $SERVICE_NAME
    fi
  fi
}

DO_SERVICE(){
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_QUERY=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'") 
  if [[ $CUSTOMER_QUERY =~ 0 ]]
  then
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_QUERY=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  CUSTOMER_ID=$(echo "$CUSTOMER_QUERY" | sed -n 3p)
  NAME_QUERY=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'") 
  CUSTOMER_NAME=$(echo "$NAME_QUERY" | sed -n 3p)
  echo -e "\nWhat time do you want?"
  read SERVICE_TIME
  APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) values ($1, $CUSTOMER_ID, '$SERVICE_TIME')")
  echo "I have put you down for a $2 at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')."
}

MAIN_MENU