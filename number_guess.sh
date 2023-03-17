#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate number
SECRET_NUM=$((RANDOM % 1000 + 1))

# prompt username
echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM scoreboard WHERE username='$USERNAME'")

# Check if user in database
if [[ -n $USER_ID ]]
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM scoreboard WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM scoreboard WHERE user_id='$USER_ID'")

  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
else
  echo Welcome, $USERNAME! It looks like this is your first time here.
fi

# get first choice
echo Guess the secret number between 1 and 1000:
read CHOICE
while [[ ! $CHOICE =~ ^[0-9]+$ ]]
do
  echo That is not an integer, guess again:
  read CHOICE
done

ATTEMPTS=1

# play game
while [[ $CHOICE -ne $SECRET_NUM ]]
do

  if [[ $CHOICE -gt $SECRET_NUM ]]
  then
    echo It\'s lower than that, guess again:
  elif [[ $CHOICE -lt $SECRET_NUM ]]
  then
    echo It\'s higher than that, guess again:
  fi

  read CHOICE

  while [[ ! $CHOICE =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read CHOICE
  done

  ATTEMPTS=$((ATTEMPTS+1))

done

# register results
if [[ -z $USER_ID ]]
then 
  REGISTER_SCORE_RESULT=$($PSQL "INSERT INTO scoreboard(username,best_game,games_played) VALUES('$USERNAME',$ATTEMPTS,1)")
else
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE scoreboard SET games_played=$GAMES_PLAYED+1 WHERE user_id='$USER_ID'")
  if [[ $ATTEMPTS -lt $BEST_GAME ]]
  then 
    UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE scoreboard SET best_game=$ATTEMPTS WHERE user_id='$USER_ID'")
  fi
fi

echo You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUM. Nice job!