simulations <- 10000

source("strategy1.R")
glue::glue("For Chester's strategy, a Yahtzee was obtained on ",
           "{mean(strategy1$yahtzee == TRUE) * 100}% of the ",
           "{simulations} Yahtzee simulations.")
chester_perc_yahtzee_3_rolls <- (mean(strategy1$yahtzee2 == TRUE) - 
                           mean(strategy1$yahtzee == TRUE)) * 100
glue::glue(
  "For Chester's strategy, a Yahtzee was obtained on ",
  "{chester_perc_yahtzee_3_rolls}% of the ",
  "{format(simulations, big.mark = ',')} Yahtzee simulations."
)
source("strategy2.R")
glue::glue("For the other Gumbas' strategy, a Yahtzee was obtained on ",
           "{mean(strategy2$yahtzee == TRUE) * 100}% of the ",
           "{simulations} Yahtzee simulations.")
other_perc_yahtzee_3_rolls <- (mean(strategy2$yahtzee2 == TRUE) - 
                                   mean(strategy2$yahtzee == TRUE)) * 100
glue::glue(
  "For the other Gumbas' strategy, a Yahtzee was obtained on ",
  "{other_perc_yahtzee_3_rolls}% of the ",
  "{format(simulations, big.mark = ',')} Yahtzee simulations."
)
