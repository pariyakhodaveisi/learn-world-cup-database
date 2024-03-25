#! /bin/bash

if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
  echo "Test"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
  echo "Prod"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR != "year" ]]; then
    # Check and insert winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    
    # Check and insert opponent
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
    
    # Check if game already exists
    GAME_EXISTS=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID AND year=$YEAR AND round='$ROUND' AND winner_goals=$WINNER_GOALS AND opponent_goals=$OPPONENT_GOALS")
    if [[ -z $GAME_EXISTS ]]; then
      # If game does not exist insert it
      $PSQL "INSERT INTO games(winner_id, opponent_id, winner_goals, opponent_goals, year, round) VALUES ($WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS, $YEAR, '$ROUND')"
    else
      echo "Game already exists: Year $YEAR, Round '$ROUND', Teams $WINNER vs $OPPONENT"
    fi
  fi
done
