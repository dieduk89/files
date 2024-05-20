#!/bin/bash
if [[ $# -eq 0 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $# -gt 1 ]]
  then
    echo "Please provide only one argument."
  else
    PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
    BASE_QUERY="SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id)"
    if [[ $1 =~ ^[0-9]+$ ]]
    then
      # find element by atomic number
      CONDITION="WHERE atomic_number = $1;"
    else
      # find element by symbol or name
      CONDITION="WHERE symbol = '$1' OR name = '$1'"
    fi
    RESULT=$($PSQL "$BASE_QUERY $CONDITION")
    if [[ -z $RESULT ]]
    then
      echo "I could not find that element in the database."
    else
      IFS="|" read -ra VALUES <<< "$RESULT"
      echo "The element with atomic number ${VALUES[0]} is ${VALUES[1]} (${VALUES[2]}). It's a ${VALUES[3]}, with a mass of ${VALUES[4]} amu. ${VALUES[1]} has a melting point of ${VALUES[5]} celsius and a boiling point of ${VALUES[6]} celsius."
    fi
  fi
fi