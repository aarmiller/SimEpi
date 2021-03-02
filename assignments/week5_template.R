
############################################################
### Assignment 5 - Simulation In Epidemiology Spring 2021
### Due Date: 2/4/2021
############################################################

### Your Name: 

library(tidyverse)
library(lubridate)


########################
#### Build the Game ####
########################

## Build the game board  -------------------------------------------------------

initialize_game <- function(){
  
}

## Check available moves -------------------------------------------------------

available_moves <- function(board){
  
}

##  Make a random move ---------------------------------------------------------

random_move <- function(){
  
}

## Check win status ------------------------------------------------------------

check_win <- function(){
  
}

############################
#### Implement the Game ####
############################

# Note: feel free to make changes to the following structure if you have an 
#       alternative way to iterate

# start the game
board <- initialize_game() 

# loop over rounds
for (i in 1:9){
  
  # determine which player's turn it is
  
  # Optional: find available moves if using the second approach described above, if
  # using the first approach this will be impeded in the random_moves() function
  # available_moves()
  
  # make a random move based on what is available (note: if you use the first approach
  # outlined above this function should take a board game, find the available moves, then
  # return the board
  random_move()
  
  # Optional: If you choose the second approach outlined, you will need to update the 
  # the board game after you pick a random move.
  
  # check if anyon has won...if so you will need to exit the loop
  check_win()
  
  # if someone won use the break command to stop the loop
  
}


## Now implement as a function -------------------------------------------------

run_game <- function(){
  
}

############################
#### Advanced Questions ####
############################

## Make the computer more realistic --------------------------------------------

# 1) Try to win, when possible
# 2) Block you opponent if they can win




## Make a user interface -------------------------------------------------------

# Require input from the user at alternating turns, to play against the computer




## Print a Game Board ----------------------------------------------------------

# After each consecutive play print the board game, so the use can see the available
# spaces


