# Feedback Stackelberg Equilibrium of Dynamic Games
This repo computes feedback SG equilibrium of dynamic SG game using MILP and dynamic programming. 

The dynamic SG game settings:
- player 1 is the leader and player 2 is the follower;
- finite state and finite actions;
- discrete time;
- Markov transition kernel.

The purposes are the following:
- verify if feedback SG equilirbium will be stationary when $T\to\infty$;
- design some learning algorithms based on Bellman equations for SG.

The game is defined as follows.
$$
\min_{\pi^1 \in \Delta(|\mathcal{A^1}|), \pi^{2*}} \quad \mathbb{E}_{\pi^1, \pi^{2*}}\left[ \sum_{t=0}^T \gamma^t r^1(S_t, A^1_t, A^2_t) | S_0 = s \right] \\ 
\text{s.t.} \quad \pi^{2*} \in \arg\min_{\pi^2 \in \Delta(|\mathcal{A^2}|)} \mathbb{E}_{\pi^1, \pi^{2}} \left[ \sum_{t=0}^T \gamma^t r^2(S_t, A^1_t, A^2_t) | S_0 = s \right], \\ 
$$
Here, $S_t, A^i_t$ are the state and actions at time $t$, which are random variables; $r^i$ is the stage cost functions. The transition probability is denoted by $p(s'|s,a^1, a^2)$. Note that we consider feedback strategies $\pi^i$, i.e., $\pi^i(\cdot | s)$ is a probability distribution over $\mathcal{A}^i$, $i \in \{1,2\}$. If $T$ is finite, the policy is non-stationary and is a sequence $\{ \pi^i_t(\cdot | s) \}_{t=0}^T$, $i \in \{ 1,2 \}$.


### Methods
For finite horizon SG, we can use dynamic programming to compute feedback SG equilibrium. At stage $t$, we have a bilevel optimization problem, specifically a bilinear problem:
$$
\min_{x,y^*} \quad x^T U y \\
\text{s.t.} \quad y^* = \arg\min_y x^T V y,
$$ 
where $x,y$ are policies and $U,V$ are accumulated cost. We use KKT conditions to eliminate the lower-level problem and reformulate it into a mixed-integer linear programming (see [^1], [^2]). Using existing integer solvers such as Gurobi, we can compute the feedback SG equilibrium backward.


### MARL problems
In MARL settings, people are interested in **stationary policies** under $T\to \infty$. We note that the stationary policy is still a feedback policy because it depends on the state. However, it can be hard to compute the stationary policy directly. We use finite horizon problem to approximate the infinte horizon problem.


### Conclusion: 
- For discounted cases. The value and policy are stationary as time $T\to\infty$;
 - the follower's strategy is always deterministic.
 - the leader's strategy may not be deterministic due to the BR partition.
- For non-discounted cases, the cost does not converge unless there is an absorbing state.

[^1]: Paruchuri, Praveen, et al. "Playing games for security: An efficient exact algorithm for solving Bayesian Stackelberg games." Proceedings of the 7th international joint conference on Autonomous agents and multiagent systems-Volume 2. 2008.

[^2]: Zhao, Yuhan, et al. "Stackelberg strategic guidance for heterogeneous robots collaboration." 2022 International Conference on Robotics and Automation (ICRA). IEEE, 2022.
