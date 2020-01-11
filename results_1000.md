
``` r
simulations <- params$simulations
source("strategy1.R")
```

For Chester’s strategy, a Yahtzee was obtained on 0.1% of the 1,000
Yahtzee simulations.

``` r
chester_perc_yahtzee_3_rolls <- (mean(strategy1$yahtzee2 == TRUE) - 
                           mean(strategy1$yahtzee == TRUE)) * 100
```

For Chester’s strategy, a Yahtzee was obtained on 1.5% of the 1,000
Yahtzee simulations.

``` r
source("strategy2.R")
```

For the other Gumbas’ strategy, a Yahtzee was obtained on 0.4% of the
1,000 Yahtzee simulations.")

``` r
other_perc_yahtzee_3_rolls <- (mean(strategy2$yahtzee2 == TRUE) - 
                                   mean(strategy2$yahtzee == TRUE)) * 100
```

For the other Gumbas’ strategy, a Yahtzee was obtained on 1% of the
1,000 Yahtzee simulations."
