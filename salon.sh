#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon el sumidero ~~~~\n"

MAIN_MENU(){

#pa imprimir la info
if [[ $1 ]]
then 
echo -e "\n$1\n"
fi

SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo -e "\nBienvenido al salon 'El Sumidero', ¿como podemos ayudarte?\n"
echo "$SERVICES" | while read SERVICE_ID BAR NAME BAR
do
  echo "$SERVICE_ID) $NAME "
  
done

read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$  ]]
then
  #send to main menu
  MAIN_MENU "Por favor ingresa una opcion valida"
else
  SERVICE_ID_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    #send to main menu
    MAIN_MENU "Ese servicio no existe"
  else
    #MAKE AN APPOINTMENT
    APPT_MENU $SERVICE_ID_SELECTED
  fi
fi

}



APPT_MENU(){
  SERVICE_NAME=$1
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name='$SERVICE_NAME'")
  echo -e "\n¿Cual es tu numero de telefono?\n"
  #GET PHONE NUMBER
  read CUSTOMER_PHONE
  #get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if not customer
  if [[ -z $CUSTOMER_ID ]]
  then
    #no record, get name
    echo -e "\nI don't havee a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    echo -e "\n What time would you like to $SERVICE_NAME, $CUSTOMER_NAME"
    read SERVICE_TIME
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    
    if [[ $CUSTOMER_INSERT_RESULT ]]
    then
      
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      APPT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  else
  #si hay cliente
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")
      echo -e "\n What time would you like to $SERVICE_NAME, $CUSTOMER_NAME"
      read SERVICE_TIME
      APPT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}



MAIN_MENU
