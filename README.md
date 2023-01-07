# feedback-sg-test
This repo computes feedback SG equilibrium for a simple dynamic SG game using MILP and DP.

The purposes are the following:
- verify if feedback SG equilirbium will be stationary when $T\to\infty$;
- verify if feedback SG equilibrium = global SG equilirbium when $T\to\infty$;
- design some learning algorithms based on Bellman equations for SG.

The game settings:
- finite state and finite actions;
- discrete time.

Conclusion: 
- For discounted cases. the value and policy are stationary as time $T\to\infty$;
 - the follower's strategy is always deterministic.
 - the leader's strategy may not be deterministic due to the BR partition.
- For non-discounted cases, the cost does not converge unless there is an absorbing state.