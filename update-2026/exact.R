# Yahtzee endgame: from "first roll all different", which is better for chasing a Yahtzee?
#
#   Strategy 1 (keep one):   hold one die, reroll the other 4 on the 2nd roll, then keep the
#                            largest matching group and reroll the rest on the 3rd roll.
#   Strategy 2 (reroll all): reroll all 5 on the 2nd roll, then complete the same way.
#
# The state space is tiny, so we DON'T need to simulate to answer this. The 2nd roll has
# only 6^5 = 7776 equally likely outcomes (Strategy 2) or 6^4 = 1296 once the held die is
# fixed (Strategy 1), and the final roll contributes a closed (1/6)^need. Enumerate every
# case and you get the exact answer:
#
#   P(Yahtzee) = 221/17496 = 0.0126315  (about 1 in 79.2)  --  EXACTLY EQUAL for both.
#
# The companion Monte Carlo below keeps a million trials only to show they collapse back to
# this exact computation once duplicate rolls are removed.

# ---- Exact answer by full enumeration -----------------------------------------------------

# Optimal completion is a pure number: if the best matching group of 5 dice has size `have`,
# the final roll completes the Yahtzee with probability (1/6)^(5 - have). No die is rolled.
# We tally every 2nd-roll outcome by its best group size (the only thing that matters), then
# average. tabulate() indexes by face directly (1..6) -- no table()/names() juggling.
enumerate <- function(strategy) {
  k    <- if (strategy == 1L) 4L else 5L
  grid <- as.matrix(expand.grid(rep(list(1:6), k)))   # 6^k rows, all equally likely
  shape <- integer(5)                                  # count of outcomes by best group size
  for (i in seq_len(nrow(grid))) {
    # By symmetry an all-different first roll and the choice of held die don't matter, so we
    # fix the held die (Strategy 1) to face 1. Strategy 2 rerolls all five.
    dice5 <- if (strategy == 1L) c(1L, grid[i, ]) else grid[i, ]
    have  <- max(tabulate(dice5, nbins = 6L))
    shape[have] <- shape[have] + 1L
  }
  shape_p <- shape / nrow(grid)                        # exact P(best group = 1..5)
  # Win prob depends only on the best group size, so averaging over this histogram is the
  # exact mean over all outcomes -- and identical shapes give bit-identical answers.
  list(p = sum(shape_p * (1/6)^(5L - 1:5)), shape = shape_p, n = nrow(grid))
}

e1 <- enumerate(1L)   # Strategy 1 (keep one)
e2 <- enumerate(2L)   # Strategy 2 (reroll all)
P_EXACT <- e2$p       # = 221/17496

cat("=== Exact, by enumeration (no simulation) ===\n")
cat(sprintf("Strategy 1 (keep one):   %5d outcomes  ->  P = %.10f\n", e1$n, e1$p))
cat(sprintf("Strategy 2 (reroll all): %5d outcomes  ->  P = %.10f\n", e2$n, e2$p))
cat(sprintf("221 / 17496            :              ->  P = %.10f\n", 221 / 17496))
cat(sprintf("Exact difference (S1 - S2): %g   (about 1 in %.1f)\n\n", e1$p - e2$p, 1 / P_EXACT))

# ---- A million trials, then remove the duplicates -----------------------------------------
# Keeps the big simulation, but shows it adds nothing: a million 2nd rolls contain only a
# few distinct situations, and the MC estimate is just their frequencies weighted by the
# exact completion probabilities. Strategy 2 carries the whole story (same shape dist as S1).

set.seed(123)
n_sims <- 1e6
draws  <- matrix(sample.int(6, n_sims * 5L, replace = TRUE), ncol = 5L)  # n_sims 2nd rolls
counts <- sapply(1:6, function(f) rowSums(draws == f))                   # face counts, n x 6
best   <- do.call(pmax, as.data.frame(counts))                          # best group size each

n_multisets <- nrow(unique(counts))            # distinct dice combinations actually seen
n_classes   <- length(unique(best))            # distinct situations that change the answer
emp         <- tabulate(best, 5L) / n_sims      # empirical shape distribution

est_mc <- sum(emp * (1/6)^(5L - 1:5))           # MC estimate = frequencies x exact completion
se_mc  <- sqrt(est_mc * (1 - est_mc) / n_sims)

cat("=== A million trials, deduplicated ===\n")
cat(sprintf("Rolls drawn:                       %s\n", format(n_sims, big.mark = ",", scientific = FALSE)))
cat(sprintf("Distinct dice combinations seen:   %d  (of %d possible)\n", n_multisets, choose(10, 5)))
cat(sprintf("Situations that change the answer: %d  (best group size, 1..5)\n\n", n_classes))

cat("Share of trials by best group size (noisy empirical vs exact):\n")
print(round(rbind(Empirical = emp, Exact = e2$shape), 6))

cat(sprintf("\nMonte Carlo estimate (empirical weights): %.6f  (SE = %.6f)\n", est_mc, se_mc))
cat(sprintf("Exact (duplicates removed)              : %.6f  (= 221/17496)\n", P_EXACT))
cat(sprintf("Difference                              : %+.2e\n", est_mc - P_EXACT))
cat("\nSwap the empirical frequencies for their exact values -- i.e. remove the sampling\n")
cat("noise the duplicate rolls carry -- and the estimate becomes 221/17496 exactly.\n")
cat("That swap IS the enumeration above.\n")
