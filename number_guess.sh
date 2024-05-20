#!/bin/bash

function CHECKCOND(){
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    if [[ $1 -gt $NUMBER ]]
    then
      COND=1
    else
      if [[ $1 -lt $NUMBER ]]
      then
        COND=2
      else
        COND=3
      fi
    fi
  else
    COND=0    
  fi
}

PSQL="psql --username=freecodecamp --dbname=guess_data -t --no-align -c"
NUMBER=$(($RANDOM % 1000 + 1))
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
if [[ -z $USER_ID ]]
then
  USER_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  QUERY=$($PSQL "SELECT count(game_id), min(tries) FROM games WHERE user_id = $USER_ID")
  IFS="|" read -ra VALUES <<< "$QUERY"
  echo "Welcome back, $USERNAME! You have played ${VALUES[0]} games, and your best game took ${VALUES[1]} guesses."
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1
CHECKCOND $GUESS
while [[ $COND -ne 3 ]]
do
  case $COND in
    0) echo "That is not an integer, guess again:" ;;
    1) echo "It's lower than that, guess again:" ;;
    2) echo "It's higher than that, guess again:" ;;
    *) ;;
  esac
  read GUESS
  TRIES=$(( $TRIES +1 ))
  CHECKCOND $GUESS
done
echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
GAME_INSERT=$($PSQL "INSERT INTO games(user_id, tries) VALUES($USER_ID, $TRIES)")