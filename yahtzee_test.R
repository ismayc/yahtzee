library(purrr)
library(dplyr)
library(janitor)

set.seed(2020)

roll <- function(die = 1:6, num_dice = 5, replace = FALSE){
  sample(die, size = num_dice, replace = replace)
#  dice <- vector(mode = "integer", length = num_dice)
#  for(i in seq_along(num_dice))
#    dice[i] <- sample(die, size = 1, )
    
}

reps <- 1000000

# Only focus on first rolls that have all
# different dice
first_rolls <- list()

for(i in seq_len(reps))
  first_rolls[[i]] <- roll(replace = TRUE)

# Create a list-column of first rolls in a tibble
yahtzee_rolls <- tibble(first_rolls)

yahtzee_gotten <- function(dice){
  all(dice[1] == dice)
}

yahtzee_rolls <- yahtzee_rolls %>% 
  mutate(yahtzee = map_lgl(first_rolls, yahtzee_gotten))

mean(yahtzee_rolls$yahtzee == TRUE) * 100
