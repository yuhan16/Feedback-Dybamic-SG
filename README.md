# feedback-sg-test
This repo computes feedback SG equilibrium for a simple dynamic SG game using MILP and DP.

The purposes are the following:
- verify if feedback SG equilirbium will be stationary when $T\to\infty$;
- verify if feedback SG equilibrium = global SG equilirbium when $T\to\infty$;
- design some naive learning methods based on Bellman equations for SG.

The game settings:
- finite state and finite actions;
- discrete time.