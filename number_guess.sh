#!/bin/bash
# SQL global variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_OF_TRIES=0

check_user_exists() {
  USERNAME=$($PSQL "SELECT username FROM users WHERE username ILIKE '$1'")
  [[ -n $USERNAME ]]
}

game_loop() {
  # Game loop
  NUMBER_OF_TRIES=0

  echo "Guess the secret number between 1 and 1000: "
  while [[ true ]]
  do
    read GUESS

    NUMBER_OF_TRIES=$(( $NUMBER_OF_TRIES + 1 ))
    
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again: "
      continue
    fi

    if [[ $GUESS == $1 ]]
    then
      echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $1. Nice job!"
      break
    elif (( $GUESS > $1 ))
    then
      echo "It's lower than that, guess again: "
    else
      echo "It's higher than that, guess again: "
    fi
  done
}

# Generate random number between 1-1000
RANDOM_NUMBER=$(( ($RANDOM % 3) + 1 ))

# Grab user input
echo "Enter your username: "
read NAME

# Check if user exists
if check_user_exists $NAME 
then
  RESULT=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$NAME'")
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<< "$RESULT"
  echo -e "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
  game_loop $RANDOM_NUMBER
  RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $NUMBER_OF_TRIES) WHERE username = '$NAME'")
else
  echo -e "Welcome, $NAME! It looks like this is your first time here.\n"
  game_loop $RANDOM_NUMBER
  RESULT=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$NAME', 1, $NUMBER_OF_TRIES)")
fi
