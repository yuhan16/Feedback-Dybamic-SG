% this script compute feedback SG equilibrium use DP in discrete settings.
% the purpose is to see if equilirbium becomes stationary as T -> inf
% we use cost instead of reward.

close all
clearvars

rng(75984)
dimS = 20;
dimA = 7;
dimB = 5;
T = 100;
gam = 0.9;
ua = 10*rand(dimS, dimA, dimB);    % stage cost
ub = 10*rand(dimS, dimA, dimB);
uaf = rand(dimS, 1);            % terminal cost
ubf = rand(dimS, 1);
p = rand(dimS, dimS, dimA, dimB);   % p(s'|s,a,b)
p = normalize_p(p);
bigM = 100;

% generate cost
UA = cell(T, 1);
UA(:) = {ua};
UA(end+1) = {uaf};
UB = cell(T, 1);
UB(:) = {ub};
UB(end+1) = {ubf};

% optimal cost
VA = cell(T+1, 1);
VB = cell(T+1, 1);

% optimal policy
x = cell(T, 1);
y = cell(T, 1);

% perform DP to compute feedback SG equilibrium
for t = T+1: -1: 1
    % terminal cost
    if t == T+1
        VA{t} = UA{t};
        VB{t} = UB{t};
        continue
    end
    
    % formulate MILP to find optimal cost and policy for each state
    VA_t = zeros(dimS, 1);
    VB_t = zeros(dimS, 1);
    x_t = zeros(dimS, dimA);
    y_t = zeros(dimS, dimB);
    for i = 1: dimS
        % perform MILP
        [MA, MB] = formulate_objmat(UA{t}, UB{t}, VA{t+1}, VB{t+1}, p, gam, i);
        f = reshape(MA', [1, dimA*dimB]);   % expand along row direction
        f = [f, zeros(1, dimB+1)];
        [A, b, Aeq, beq] = formulate_constrmat(MB, bigM);
        lb = [zeros(dimA*dimB+dimB, 1); -Inf];
        ub = [ones(dimA*dimB+dimB, 1); Inf];
        intcon = dimA*dimB+1: dimA*dimB+dimB;
        Z0 = [];
        options = optimoptions('intlinprog','Display','off');
        Z = intlinprog(f, intcon, A, b, Aeq, beq, lb, ub, Z0, options);
        
        % recover optimal strategy
        xtmp = zeros(dimA, 1);
        for j = 1: dimA
            idx = (j-1)*dimB + 1: j*dimB;
            xtmp(j) = sum(Z(idx));
        end
        x_t(i, :) = xtmp';
        y_t(i, :) = Z(dimA*dimB+1: dimA*dimB+dimB, 1)';
        
        % compute optimal cost
        VA_t(i) = x_t(i, :) * MA * y_t(i, :)';
        VB_t(i) = x_t(i, :) * MB * y_t(i, :)';
    end
    
    % store optimal cost and optimal policy
    VA{t} = VA_t;
    VB{t} = VB_t;
    x{t} = x_t;
    y{t} = y_t;
end

disp('policy x')
x{3}
x{4}
x{5}
x{6}
disp('policy y')
y{3}
y{4}
y{5}
y{6}

% plot value functions
va = zeros(dimS, T+1);
vb = zeros(dimS, T+1);
for t = 1: T+1
    va(:, t) = VA{t};
    vb(:, t) = VB{t};
end
figure
hold on
for i = 1: dimS
    plot(va(i, :))
end



%========== auxiliary functions ==========%
function [p] = normalize_p(p)
    % normalize the first dimension.
    [dimS, ~, dimA, dimB] = size(p);
    tmp = squeeze(sum(p, [1]));
    for i = 1: dimS    % for s
        for j = 1: dimA    % for a
            for k = 1: dimB    % for b
                for l = 1: dimS    % for s'
                    p(l, i,j,k) = p(l, i,j,k) / tmp(i,j,k);
                end
            end
        end
    end
end


function [MA, MB] = formulate_objmat(uA, uB, VA, VB, p, gam, s)
    % this function formulates big matrices for both leader and follower
    % s is the current state, fixed
    [dimS, ~, dimA, dimB] = size(p);
    MA = squeeze(uA(s, :, :));
    MB = squeeze(uB(s, :, :));
    for i = 1: dimA
        for j = 1: dimB
            tmpA = 0;
            tmpB = 0;
            for k = 1: dimS
                tmpA = tmpA + p(k, s, i, j) * VA(k, 1); % leader
                tmpB = tmpB + p(k, s, i, j) * VB(k, 1); % follower
            end
            MA(i, j) = MA(i, j) + gam * tmpA;
            MB(i, j) = MB(i, j) + gam * tmpB;
        end
    end
end


function [A, b, Aeq, beq] = formulate_constrmat(MB, bigM)
    % this function formulates constraint matrices.
    [dimA, dimB] = size(MB);
    
    % sum_{i,j} Z_ij = 1; sum_j y_j = 1
    Aeq = zeros(2, dimA*dimB + dimB + 1);
    Aeq(1, 1: dimA*dimB) = ones(1, dimA*dimB);
    Aeq(2, dimA*dimB+1: dimA*dimB+dimB) = ones(1, dimB);
    beq = [1;1];
    
    A = [];
    b = [];
    % sum_j Z_ij <= 1, i=1,...,dimA
    for i = 1: dimA
        tmp = zeros(1, dimA*dimB+dimB+1);
        idx = (i-1)*dimB + 1: i*dimB;
        tmp(1, idx) = 1;
        A(end+1, :) = tmp;
        b(end+1, 1) = 1;
    end
    % sum_i Z_ij <= 1, j=1,...,dimB
    for i = 1: dimB
        tmp = zeros(1,dimA*dimB+dimB+1);
        idx = i: dimB: i+(dimA-1)*dimB;
        tmp(1, idx) = 1;
        A(end+1, :) = tmp;
        b(end+1, 1) = 1;
    end
    % sum_i Z_ij >= y_j, j=1,...,dimB
    for i = 1: dimB
        tmp = zeros(1,dimA*dimB+dimB+1);
        idx = i: dimB: i+(dimA-1)*dimB;
        tmp(1, idx) = -1;
        tmp(1, dimA*dimB+i) = 1;
        A(end+1, :) = tmp;
        b(end+1, 1) = 0;
    end
    % MB' * (Z*1_n) + mu*1_n >= 0
    C = zeros(dimA, dimA*dimB+dimB+1); % C*vec(X) = x, C is m x (mn+n+1)
    for i = 1: dimA
        idx = (i-1)*dimB + 1: i*dimB;
        C(i, idx) = 1;
    end
    for i = 1: dimB
        tmp = MB(:, i)' * C;
        tmp(end) = 1;
        A(end+1, :) = -tmp; % note the "-" sign
        b(end+1, 1) = 0;
    end
    % MB' * (Z*1_n) + mu*1_n <= M(1_n - y)
    for i = 1: dimB
        tmp = MB(:, i)' * C;
        tmp(end) = 1;
        tmp(dimA*dimB+i) = bigM;
        A(end+1, :) = tmp;
        b(end+1, 1) = bigM;
    end
end

