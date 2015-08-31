function out = getPf(clique, M, betaC, alpha, L)
%% V2(fi,fi') & Uf
Uf = zeros(1,M);
for j = 1:M
    V2 = zeros(1,8);
    for i = 1:8
        if isnan(clique{i}(2))
            
        else
            if L(j) == clique{i}(2)
                V2(i) = betaC(i);
            else
                V2(i) = -betaC(i);
            end
        end
    end
    Uf(j) = alpha*L(j) + sum(V2);
end

%% conditional probability
Pf = zeros(1,M);
% Uf
for k = 1:M
    Pf(k) = exp(Uf(k))/(sum(exp(Uf)));
    
end
%sum(Pf)
out = Pf;

end