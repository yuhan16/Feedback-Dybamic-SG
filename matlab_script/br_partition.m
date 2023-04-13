% this script computes and plots BR function for non-myopic follower.
% the follower solves a different infinite MDP problem from the follower.
% the purpose is to see if BR paritition is still convex non-myopic follower.

close all
clearvars
rng(12);

% parameter definition
gam = 0.6;
nS = 5;
nA = 3;
nB = 4;
pr = rand(nS, nA, nB, nS);  % pr(s, a, b -> s')
uA = cell(nS, 1);   % each cell is nA x nB matrix
uB = cell(nS, 1);
for i = 1: nS
    for j = 1: nA
        for k = 1: nB
            pr(i,j,k, :) = pr(i,j,k, :) / sum(pr(i,j,k, :));
        end
    end
    uA{i} = rand(nA, nB);
    uB{i} = rand(nA, nB);
end

% compute and plot BR
N = 3e3;
piA = zeros(nA, nS);    % piA(a|s)
piB = zeros(nB, nS);    % piB(a|s)
piA_data = cell(0);
BR_data = cell(0);

% generate samples
piA = rand(nA, nS);
for n = 1: N
    %piA = rand(nA, nS);
    %piA = piA ./ sum(piA);  % every column is a probability vector
    tmp = rand(nA, 1);
    piA(:, 2) = tmp / sum(tmp);
    [v_opt, BR] = compute_br(piA, uB, pr, gam);
    
    piA_data(end+1) = {piA};
    BR_data(end+1) = {BR};
end
plot_br_partition(nS, piA_data, BR_data);



function [v_opt, br] = compute_br(piA, uB, pr, gam)
% This function computes the BR given piA
% normalize things
nS = length(uB);
nA = size(uB{1}, 1);
nB = size(uB{1}, 2);
p = zeros(nS, nB, nS);  % pr(s, b -> s')
u = zeros(nS, nB);      % u(s,b)
for i = 1: nS   % s
    for j = 1: nB   % b
        for k = 1: nS   % s'
            % sum over a
            for ll = 1: nA
                p(i,j,k) = p(i,j,k) + pr(i,ll,j,k) * piA(ll, i);
            end
        end    
    end
    u(i,:) = piA(:, i)' * uB{i};
end

%mdp = DiscountedMDP(u, p, gam);
%[v_pi, mu_pi] = mdp.policy_iteration();
%[v_vi, mu_vi] = mdp.value_iteration();
%mdp.check_pr()

% use value iteration to compute optimal value and hence BR
k = 0;
v_k = 100*ones(nS, 1);
v_kp1 = v_k;
br_idx = zeros(nS, 1);
eps = 1e-4;
while 1
    for i = 1: nS   % for each v(s)
        % compute rhs of bellman equation
        tmp = zeros(nB, 1);
        for j = 1: nB
            tmp(j) = tmp(j) + u(i, j);
            for ll = 1: nS
                tmp(j) = tmp(j) + gam * p(i, j, ll) * v_k(ll);
            end
        end
        [v_kp1(i), br_idx(i)] = min(tmp);
    end
    
    if norm(v_kp1-v_k) < eps || k > 1e4
        v_opt = v_kp1;
        br = br_idx;
        break
    end
    v_k = v_kp1;
    k = k + 1;
end
%[v_pi v_vi v_opt]
end


function plot_br_partition(nS, piA_data, BR_data)
N = length(piA_data);
for i = 1: nS
    figure()
    for k = 1: N
        piA = piA_data{k};
        br = BR_data{k};
        if br(i) == 1
            plot3(piA(1,i), piA(2,i), piA(3,i), 'bx');
        elseif br(i) == 2
            plot3(piA(1,i), piA(2,i), piA(3,i), 'ro');
        elseif br(i) == 3
            plot3(piA(1,i), piA(2,i), piA(3,i), 'gd');
        else
            plot3(piA(1,i), piA(2,i), piA(3,i), 'y^');
        end
        hold on
    end
    title(['s=', num2str(i)])
    xlabel('x')
    ylabel('y')
    zlabel('z')
end
end



