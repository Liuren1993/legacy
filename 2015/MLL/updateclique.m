function out = updateclique(filter)
    clique{1} = [filter(2,2),filter(1,2)];
    clique{2} = [filter(2,2),filter(3,2)];
    clique{3} = [filter(2,2),filter(2,1)];
    clique{4} = [filter(2,2),filter(2,3)];
    clique{5} = [filter(2,2),filter(1,3)];
    clique{6} = [filter(2,2),filter(3,1)];
    clique{7} = [filter(2,2),filter(3,3)];
    clique{8} = [filter(2,2),filter(1,1)];
    out = clique;
end