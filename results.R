
#simulations <- c(1e3, 1e4, 1e5, 1e6, 1e7)

simulations <- c(1e5, 1e6, 1e7)

analysis <- function(num_simulations){
  
  source("strategy1.R", local = TRUE)
  source("strategy2.R", local = TRUE)
  
  readr::write_rds(
    strategy1, 
    glue::glue("chester_{num_simulations}-simulations.rds")
  )
  readr::write_rds(
    strategy2, 
    glue::glue("other_{num_simulations}-simulations.rds")
  )
}

purrr::walk(simulations, analysis)
analysis(num_simulations = simulations[1])
analysis(simulations[2])
analysis(simulations[3])