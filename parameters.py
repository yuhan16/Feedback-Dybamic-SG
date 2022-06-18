import numpy as np

rng = np.random.default_rng(12345)
# problem parameters
gam = 0.6
nS = 3
nA = 3
nB = 2
uA = rng.random.rand(nS, nA, nB)     # uA(s, a, b)
uB = rng.random.rand(nS, nA, nB)     # uB(s, a, b)
pr = rng.random.rand(nS, nA, nB, nS) # pr(s, a, b -> s')
for i in range(nS):
    for j in range(nA):
        for k in range(nB):
            pr[i,j,k,:] = pr[i,j,k,:] / pr[i,j,k,:].sum()
