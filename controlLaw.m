function [input] = controlLaw(agent_coords, agent_destinations, alphas, Kgains, G_connections, formation_sep)
    %use the simple control law to figure out what controw law to apply to
    %robots
    %assume single robot for now.
    %coords is an N*2 matrix, so is agent destinations
    %note: we want to enforce criteria here, namely:
    % r_i - r_i+1 = di = formation_sep
    s = elementwiseSumCompute( agent_coords, agent_destinations, Kgains, G_connections, formation_sep);
    u = - alphas * (agent_coords - agent_destinations) + s; 
    input = u
end