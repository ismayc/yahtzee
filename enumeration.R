`%>%` <- dplyr::`%>%`

die <- 1:6

die1 <- die2 <- die3 <- die4 <- die5 <- die

all_first_rolls <- tidyr::crossing(die1, die2, die3, die4, die5) #%>% 
#  mutate(as_vector = purrr::map(die1, c, die2, die3, die4, die5))

as_vector <- list()
for(i in seq_len(nrow(all_first_rolls))){
  as_vector[[i]] <- c(
    all_first_rolls$die1[i],
    all_first_rolls$die2[i],
    all_first_rolls$die3[i],
    all_first_rolls$die4[i],
    all_first_rolls$die5[i]
  )
}

all_first_rolls <- all_first_rolls %>% 
  dplyr::mutate(as_vector = as_vector) 

find_die_match <- function(dice, to_find){
  to_find %in% dice
}

duplicates_count <- function(dice){
  sum(duplicated(dice))
}

yahtzee_rolled <- function(dice){
  all(dice[1] == dice)
}

all_first_rolls <- all_first_rolls %>% 
  dplyr::mutate(yahtzee = purrr::map_lgl(as_vector, yahtzee_rolled)) %>% 
  dplyr::mutate(with_1 = purrr::map_lgl(
    as_vector, find_die_match, to_find = 1),
    with_2 = purrr::map_lgl(
      as_vector, find_die_match, to_find = 2),
    with_3 = purrr::map_lgl(
      as_vector, find_die_match, to_find = 3),
    with_4 = purrr::map_lgl(
      as_vector, find_die_match, to_find = 4),
    with_5 = purrr::map_lgl(
      as_vector, find_die_match, to_find = 5),
    with_6 = purrr::map_lgl(
      as_vector, find_die_match, to_find = 6)
    ) %>% 
  dplyr::mutate(duplicates = purrr::map_int(as_vector, duplicates_count))

janitor::tabyl(all_first_rolls$duplicates)

different_dice <- all_first_rolls %>% 
  dplyr::filter(duplicates == 0)

rolls_with_1 <- all_first_rolls %>% dplyr::filter(with_1 == TRUE) %>% 
  dplyr::select(die1:as_vector, yahtzee)
rolls_with_2 <- all_first_rolls %>% dplyr::filter(with_2 == TRUE) %>% 
  dplyr::select(die1:as_vector, yahtzee)
rolls_with_3 <- all_first_rolls %>% dplyr::filter(with_3 == TRUE) %>% 
  dplyr::select(die1:as_vector, yahtzee)
rolls_with_4 <- all_first_rolls %>% dplyr::filter(with_4 == TRUE) %>% 
  dplyr::select(die1:as_vector, yahtzee)
rolls_with_5 <- all_first_rolls %>% dplyr::filter(with_5 == TRUE) %>% 
  dplyr::select(die1:as_vector, yahtzee)
rolls_with_6 <- all_first_rolls %>% dplyr::filter(with_6 == TRUE) %>% 
  dplyr::select(die1:as_vector, yahtzee)

lookup_possible_rolls <- function(chosen_die){
  
  if(chosen_die == 1)
    rolls_with_1
  else if(chosen_die == 2)
    rolls_with_2
  else if(chosen_die == 3)
    rolls_with_3
  else if(chosen_die == 4)
    rolls_with_4
  else if(chosen_die == 5)
    rolls_with_5
  else if(chosen_die == 6)
    rolls_with_6
  
  # dplyr::case_when(
  #   (chosen_die == 1) ~ rolls_with_1,
  #   (chosen_die == 2) ~ rolls_with_2,
  #   (chosen_die == 3) ~ rolls_with_3,
  #   (chosen_die == 4) ~ rolls_with_4,
  #   (chosen_die == 5) ~ rolls_with_5,
  #   (chosen_die == 6) ~ rolls_with_6
  # )
}


chesters <- different_dice %>% 
  dplyr::mutate(chosen_die = purrr::map_int(as_vector, sample, size = 1)) %>% 
  dplyr::mutate(possible_second_rolls = purrr::map(
    chosen_die, lookup_possible_rolls)
    )

