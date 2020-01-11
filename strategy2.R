library(purrr)
library(dplyr)
library(janitor)

set.seed(2019)

# Strategy 2
strategy2 <- yahtzee_rolls

second_roll <- list()
for(i in seq_len(num_simulations)){
  second_roll[[i]] <- roll(replace = TRUE)
}

strategy2 <- strategy2 %>% 
  mutate(second_roll = second_roll) %>% 
  mutate(yahtzee = map_lgl(second_roll, yahtzee_gotten))

third_roll_decisions2 <- function(after_second_roll){
  
  freq_table <- tabyl(after_second_roll)
  names(freq_table)[1] <- "dice"
  
  if(max(freq_table$percent) >= 0.6){
    die_to_keep <- freq_table %>% 
      filter(percent == max(percent)) %>% 
      pull(dice)
  } else if(max(freq_table$percent) >= 0.4){
    # One pair or Two pair case
    # WLOG: If multiple duplicates just choose the first one
    die_to_keep <- which(duplicated(after_second_roll)) %>% 
      after_second_roll[.] %>% 
      unique() %>% 
      .[1]
  } else {
    # Try to roll 5 of anything
    die_to_keep <- roll(replace = TRUE)
  }
  keep_these_dice <- after_second_roll[after_second_roll == die_to_keep]
  
  if(length(keep_these_dice) == 5)
    keep_these_dice
  else{
    remaining_dice <- after_second_roll[after_second_roll != die_to_keep]
    after_roll <- roll(die = 1:6, num_dice = length(remaining_dice),
                       replace = TRUE)
    c(keep_these_dice, after_roll)
  }
}

third_roll <- list()
for(i in seq_len(num_simulations))
  third_roll[[i]] <- third_roll_decisions2(strategy2$second_roll[[i]])

strategy2 <- strategy2 %>% 
  mutate(third_roll = third_roll) %>% 
  mutate(yahtzee2 = map_lgl(third_roll, yahtzee_gotten))

of_a_kind <- vector(mode = "integer", length = num_simulations)
for(i in seq_len(num_simulations)){
  if(any(duplicated(third_roll[[i]])))
    of_a_kind[i] <- sum(duplicated(third_roll[[i]])) + 1
  else
    of_a_kind[i] <- 1
}

strategy2 <- strategy2 %>% 
  mutate(of_a_kind = of_a_kind) %>% 
  arrange(of_a_kind)