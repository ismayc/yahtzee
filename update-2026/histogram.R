# Companion to testing.R: the distribution of the BEST matching group size after the 2nd
# roll -- the intermediate state that drives the whole result.
#
# Key point: this distribution is the same for both strategies, and that is exactly why they
# tie. Holding one die at face 1 and rerolling 4 produces the SAME group-shape distribution
# as rerolling all 5, because conditioning one die of a fair roll on a fixed value leaves the
# shape distribution unchanged (face symmetry). Both equal the exact 5-dice shape
# distribution, so both finish with P(Yahtzee) = 221/17496 = 0.0126315. See testing.R.

# ---- Exact shape distribution by enumeration ----------------------------------------------
# For each strategy, enumerate every 2nd-roll outcome and tally the best group size.
enumerate_shape <- function(strategy) {
  k    <- if (strategy == 1L) 4L else 5L
  grid <- as.matrix(expand.grid(rep(list(1:6), k)))   # 6^k equally likely outcomes
  shape <- integer(5)
  for (i in seq_len(nrow(grid))) {
    dice5 <- if (strategy == 1L) c(1L, grid[i, ]) else grid[i, ]  # held die fixed to 1 (S1)
    have  <- max(tabulate(dice5, nbins = 6L))
    shape[have] <- shape[have] + 1L
  }
  setNames(shape / nrow(grid), paste0(1:5, "-of-a-kind"))
}

s1_shape <- enumerate_shape(1L)
s2_shape <- enumerate_shape(2L)

# Theoretical shape distribution of 5 fair dice (ordered counts / 7776):
#   1..5-of-a-kind = 720 / 5400 / 1500 / 150 / 6
theory <- setNames(c(720, 5400, 1500, 150, 6) / 7776, paste0(1:5, "-of-a-kind"))

cat("=== Exact P(best group after 2nd roll = k), by enumeration ===\n")
print(round(rbind(`Theory (5 dice)` = theory,
                  `Strategy 1`      = s1_shape,
                  `Strategy 2`      = s2_shape), 6))
cat(sprintf("\nMax difference between the two strategies: %g  (identical -> same Yahtzee odds)\n\n",
            max(abs(s1_shape - s2_shape))))

# ---- A million trials collapse onto the exact distribution --------------------------------
# The empirical histogram from a large simulation simply converges to the exact one above;
# the duplicate rolls only sharpen the estimate, they add no new situations.
set.seed(123)
n_sims <- 2e6
draws  <- matrix(sample.int(6, n_sims * 5L, replace = TRUE), ncol = 5L)
counts <- sapply(1:6, function(f) rowSums(draws == f))
best   <- do.call(pmax, as.data.frame(counts))
emp    <- setNames(tabulate(best, 5L) / n_sims, paste0(1:5, "-of-a-kind"))

cat(sprintf("=== Empirical from %s trials (Strategy 2) ===\n", format(n_sims, big.mark = ",", scientific = FALSE)))
print(round(rbind(Empirical = emp, Exact = s2_shape), 6))
cat(sprintf("\nMax empirical error: %.2e  (-> 0 as trials grow; the exact row needs no trials)\n",
            max(abs(emp - s2_shape))))
