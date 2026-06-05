# Findings (2026 update): the two strategies are exactly equal

*Revisiting the 2019 analysis in this repo seven years later.*

## TL;DR

From the "first roll all different" position, with two rolls left to chase a Yahtzee:

> **Both strategies give exactly the same chance of a Yahtzee:**
> **P = 221 / 17496 = 0.0126315 ≈ 1.2632%, about 1 in 79.2.**

- **Strategy 1 — keep one die, reroll four** ("Chester's strategy"), and
- **Strategy 2 — reroll all five** ("the other Gumbas' strategy")

are not just close — they are *provably identical*. The original simulation was, in
aggregate, basically right (its totals straddle the true value), but it never summed the
numbers into a verdict, never reported uncertainty, and never reached the exact answer that
the (tiny) state space makes available.

## The exact answer, and why it's a tie

The whole space is small enough to enumerate — no simulation required. The second roll has
only `6^5 = 7776` equally likely outcomes (Strategy 2) or `6^4 = 1296` once the held die is
fixed (Strategy 1). If the best matching group after the second roll has size *k*, the final
roll completes the Yahtzee with probability `(1/6)^(5−k)`. Averaging over the exact shape
distribution of five dice gives

```
P = (1/7776) · ( 720·(1/6)^4 + 5400·(1/6)^3 + 1500·(1/6)^2 + 150·(1/6) + 6 )
  = (884/9) / 7776
  = 221 / 17496
  ≈ 0.0126315
```

**Why the two strategies tie (one-line proof).** After the second roll both strategies face
the identical decision: keep the largest matching group, reroll the rest. So only the
*distribution of the five dice* entering that decision could differ. Strategy 2 produces
five fair dice; Strategy 1 produces one fixed die plus four fair dice. These have the **same
distribution of group shapes**, because conditioning one die of a fair roll on a fixed value
leaves the shape distribution unchanged (face symmetry). Same input distribution + same
decision rule ⟹ same probability. ∎

A nice corollary: the strategies are equal *at every stage*. The chance of a Yahtzee already
on the second roll is `(1/6)^4 = 1/1296 ≈ 0.0772%` for **both** (Strategy 1 needs four
rerolled dice to match the held one; Strategy 2 needs all five equal, `6/7776 = (1/6)^4`).

## How this lines up with the original 2019 simulation

The original `results.md` reported the second-roll percentage and the *incremental* third-roll
percentage separately, at increasing sample sizes, but never added them up. Summing the
1,000,000-trial row and comparing to the exact value:

| quantity | Strategy 1 (keep one) | Strategy 2 (reroll all) | exact (both) |
| --- | ---: | ---: | ---: |
| Yahtzee on 2nd roll | 0.0757% | 0.0805% | **0.0772%** |
| extra from 3rd roll | 1.1806% | 1.1973% | **1.1860%** |
| **total** | **1.2563%** | **1.2778%** | **1.2632%** |

Both totals sit within Monte-Carlo noise of `221/17496` (the standard error at 1e6 trials is
about ±0.011 percentage points). The original table makes Strategy 2 *look* slightly better
(1.278% vs 1.256%), which is exactly the trap: that gap is sampling noise, not a real edge.
The strategies are equal.

## Faults in the original analysis

None of these change the headline much, but they're worth recording.

1. **The question was never actually answered.** `results.md` splits each strategy into a
   second-roll percentage and an *incremental* third-roll percentage and never sums them,
   reports no standard error or confidence interval, and states no conclusion. A reader
   cannot tell from the table that the two strategies are equal.

2. **No exact answer, despite a tiny space.** `enumeration.R` was started (it builds all
   7776 first rolls and filters to the all-different ones) but abandoned — it never computes
   a completion probability or a final number. Enumerating fully gives `221/17496` and
   settles the question with certainty. See `update-2026/exact.R`.

3. **Strategy 2's "all different after the second roll" branch is broken.** In
   `strategy2.R`, that branch does `die_to_keep <- roll(replace = TRUE)` (rolling *five*
   dice) and then compares it **element-wise** to the second-roll dice. Usually this
   accidentally rerolls all five (correct), but when two or more positions coincidentally
   match it "keeps" two unequal dice and forces an automatic failure. The branch therefore
   yields only **80.4%** of the intended `(1/6)^4` (`P(≤1 positional match) = 6250/7776`).
   Impact on the total is negligible — that branch contributes `(1/6)^4` weighted by the
   9.26% chance of being all-different — but it is incorrect.

4. **`of_a_kind` is miscomputed.** Both strategy scripts use
   `sum(duplicated(x)) + 1`, which equals `6 − (number of distinct faces)`, not the size of
   the largest group. A full house `(5,5,5,2,2)` is labelled **4-of-a-kind**, two pair
   `(5,5,2,2,1)` is labelled **3-of-a-kind**. It's only used to `arrange()` the output, so
   it doesn't affect the probabilities — but the column is mislabeled.

5. **The results aren't reproducible from the repo.** `results.md` reads
   `chester_*-simulations.rds` / `other_*-simulations.rds` files that were never committed,
   and the `DRIVER.R` / `results.R` scripts that generated them were deleted. As committed,
   `strategy1.R` and `strategy2.R` also don't run standalone — they reference undefined
   objects (`num_simulations` / `reps`, `yahtzee_rolls`, and an unimported `tibble`).

6. **Heavy, slow, and doubly-run machinery.** Per-row `tabyl()` calls inside list-column
   `for` loops make the simulation slow enough that it was capped at 1e6 and cached to
   `.rds`; and `results.R` ran the whole thing twice (a `purrr::walk(...)` followed by three
   explicit `analysis(...)` calls). The vectorized rewrite in `update-2026/` does 1,000,000
   trials in about a second, and the exact answer is instant.

7. **Minor inconsistency.** `strategy1.R` computes the second-roll flag with `map()` (a
   list-column) while `strategy2.R` uses `map_lgl()` (a logical vector); the downstream
   `mean(... == TRUE)` only works by coercion.

## What's in `update-2026/`

- **`exact.R`** — the exact answer by enumeration (`221/17496` for both strategies), plus a
  million-trial simulation that is shown to collapse back onto the exact computation once
  duplicate rolls are removed.
- **`histogram.R`** — the exact post-second-roll "best group size" distribution, identical
  for both strategies (the proof made concrete), with a large simulation converging to it.
- **`report.qmd`** — a self-contained Quarto write-up of all of the above
  (`quarto render report.qmd`).

The original 2019 files are left untouched as a record of the first attempt.
