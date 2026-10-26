#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

NUMBER_OF_GUESSES=1

while [[ $GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi

  read GUESS
  (( NUMBER_OF_GUESSES++ ))
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

USER_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_STATS"

NEW_GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_USER=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
else
  UPDATE_USER=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'")
fi