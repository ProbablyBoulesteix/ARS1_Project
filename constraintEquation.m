function losses = constraintEquation(agent_coords,desired_coords, formation_matrix, weights)
%let's define a constraitn equation which we can use to "score" the swarm
%performance
% we want to control two main params here:
% - The position of the bots relative to their expected positions
% - The relaive position of the bots in the swarm
% we'll provide three scoring metrics here for convenience: one for the
% position, one for the swarm adherance, one aggregate

%first, we'll assume that the "weights" part is optional, can either be
%specified or not: if it is, we'll use the provided value...otherwise it's
%equal

ploss = 0;
floss = 0;
aloss = 0;



if isempty(weights)
    w1 = 0.5;
    w2 = 0.5;
else
    w1 = weights(1);
    w2 = weights(2);
  
end
%let's first compute the scoring relative to the desired positions
for i = 1:size(agent_coords, 1)
%we'll define score as sum of all squared errors
    error = agent_coords(i) - desired_coords(i);
    error = error.*error;
    ploss = ploss + norm(error);

end
%for formation loss, remember that expected positions are encoded in the
%formation matrix. We can define formaion loss for any robot i as:
% L = sum_j [(ri - rj) - Dij]^2 where D s the formation matrix

for i = 1:size(agent_coords, 1)
    for j = 1:size(agent_coords, 1)
            ri = agent_coords(i,:);
            rj = agent_coords(j,:);
            %cell2mat(formation_matrix(i,j))
            loss = (rj - ri) - cell2mat(formation_matrix(i,j));
            loss = loss.*loss;
            floss = floss + norm(loss);

    end
end
aloss = w1*ploss + w2*floss;

losses = [ploss, floss, aloss];

end