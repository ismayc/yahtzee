# yahtzee

> **2026 update — solved exactly.** The two strategies below are *provably equal*: both give
> a Yahtzee with probability **221/17496 ≈ 0.0126315 (about 1 in 79.2)**. The original 2019
> simulation was roughly right but never summed to a conclusion or reached the exact answer.
> See [**FINDINGS.md**](FINDINGS.md) for the result, a one-line proof, and an analysis of the
> faults in the original code. Reproducible analysis is in [`update-2026/`](update-2026/).

When playing the game of Yahtzee and all that is left is to roll a Yahtzee in your last turn,
there are a couple options for how to proceed if stuck in the terrible situation of all five
dice in your first roll being different.

This project is an attempt to try to understand which of the following strategies is best.

1. Prior to the second roll, choose a die at random from the first five to hold back. 
- Then roll the remaining four dice to try to get a Yahtzee in the second turn. 
  - If a Yahtzee isn't rolled in the second roll, but there is more of a different die than 
    originally picked, hold out the duplicate dice and roll again in the third roll.
  - If stuck in the even worse position of still having all different dice, stick with what
    was originally chosen as the die after turn 1 and try to roll 4 more of that in the
    third roll.
    
2. Roll all five of the dice again for the second roll.
- If stuck in the situation after the second roll of having all different dice, again reroll all
  five dice for turn 3.
  
  
One would think that scenario 2 provides a higher probability of success, but does it?
And if so, how much better is it?
