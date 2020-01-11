suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(janitor))

set.seed(2020)
#reps <- simulations

roll <- function(die = 1:6, num_dice = 5, replace = FALSE){
  sample(die, size = num_dice, replace = replace)
}

dice_placeholder <- vector(mode = "integer", length = 5)



# Only focus on first rolls that have all different dice
## (Not sure how to do this with {purrr}?)
first_rolls <- rep(list(dice_placeholder), num_simulations)
for(i in seq_len(num_simulations))
  first_rolls[[i]] <- roll()
# Create a list-column of first rolls in a tibble
yahtzee_rolls <- tibble(first_rolls)

# Strategy 1
# 1) Choose one of the 5 digits at random
# 2) Pick that die to try to get 4 more
#    of that die to get a yahtzee

extract_remaining <- function(dice_vector, die_kept){
  dice_vector[dice_vector != die_kept] %>% 
    na.omit()
}

strategy1 <- yahtzee_rolls %>% 
  mutate(die_chosen = map_int(.x = first_rolls, .f = sample, size = 1)) %>% 
  mutate(second_roll_dice = rep(list(dice_placeholder), num_simulations))

for(i in seq_len(num_simulations)){
  strategy1$second_roll_dice[[i]] <- extract_remaining(
    dice_vector = strategy1$first_rolls[[i]],
    die_kept = strategy1$die_chosen[i]
  )
}

second_roll <- list()
for(i in seq_len(num_simulations)){
  second_roll[[i]] <- c(roll(1:6, num_dice = 4, replace = TRUE), 
                        strategy1$die_chosen[i])
}

yahtzee_gotten <- function(dice){
  all(dice[1] == dice)
}

strategy1 <- strategy1 %>% 
  mutate(second_roll = second_roll) %>% 
  mutate(yahtzee = map(second_roll, yahtzee_gotten))

third_roll_decisions <- function(after_second_roll){
  
  freq_table <- tabyl(after_second_roll)
  names(freq_table)[1] <- "dice"
  
  if(max(freq_table$percent) >= 0.6){
    die_to_keep <- freq_table %>% 
      filter(percent == max(percent)) %>% 
      pull(dice)
  } else if(max(freq_table$percent) >= 0.4){
    # One pair or two pair case
    # WLOG: If two pairs, just choose the first pair appearing
    die_to_keep <- which(duplicated(after_second_roll)) %>% 
      after_second_roll[.] %>% 
      unique() %>% 
      .[1]
  } else {
    # Keep the original die kept and try to roll 4 of that die
    die_to_keep <- after_second_roll[length(after_second_roll)]
  }
  keep_these_dice <- after_second_roll[after_second_roll == die_to_keep]
  
  if(length(keep_these_dice) == 5)
    # Move Yahtzee to third roll without rolling
    keep_these_dice
  else{
    remaining_dice <- after_second_roll[after_second_roll != die_to_keep]
    after_roll <- roll(die = 1:6, 
                       num_dice = length(remaining_dice),
                       replace = TRUE)
    c(keep_these_dice, after_roll)
  }
}

third_roll <- rep(list(dice_placeholder), num_simulations)
for(i in seq_len(num_simulations))
  third_roll[[i]] <- third_roll_decisions(strategy1$second_roll[[i]])

strategy1 <- strategy1 %>% 
  mutate(third_roll = third_roll) %>% 
  mutate(yahtzee2 = map_lgl(third_roll, yahtzee_gotten))

of_a_kind <- vector(mode = "integer", length = num_simulations)
for(i in seq_len(num_simulations)){
  if(any(duplicated(third_roll[[i]])))
    of_a_kind[i] <- sum(duplicated(third_roll[[i]])) + 1
  else
    of_a_kind[i] <- 1
}

strategy1 <- strategy1 %>% 
  mutate(of_a_kind = of_a_kind) %>% 
  arrange(of_a_kind)

