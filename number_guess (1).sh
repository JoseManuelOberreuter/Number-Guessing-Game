#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Buscar user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  # Usuario nuevo
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Usuario existente
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generar número secreto
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"

GUESS_COUNT=0

while true
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESS_COUNT++))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done

# Guardar juego
$PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)" > /dev/null

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
