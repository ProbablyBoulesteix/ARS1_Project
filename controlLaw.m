function [input] = controlLaw(agent_coords, agent_destinations, alphas, Kgains, G_connections, formation_matrix)
    %use the simple control law to figure out what controw law to apply to
    %robots
    %assume single robot for now.
    %coords is an N*2 matrix, so is agent destinations
    %note: we want to enforce criteria here, namely:
    % r_i - r_i+1 = di = formation_sep
    
    s = elementwiseSumCompute( agent_coords, agent_destinations, Kgains, G_connections, formation_matrix);
    %create consensus matrix here
    consensus_u = zeros(size(agent_coords, 1), 2);
    destination_u =  (agent_coords - agent_destinations);
    for i= 1:1:size(agent_coords, 1)
        consensus_u(i,:) = s(i,:);
        destination_u(i,:) =  destination_u(i,:)*alphas(i);
    end    
    consensus_u;
    u =  - destination_u - consensus_u; 
    input = u;
end