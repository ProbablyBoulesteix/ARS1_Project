function formation_matrix = formation(type, numAgents, args)
% preconstruct a formation matrix given set params
if strcmp(type, 'line')
% in this case arg is [X, Y] seperation of robots in swarm
formation_matrix = cell(numAgents,numAgents);
    for i = 1:numAgents
        for j = 1:numAgents
            if i == j
                formation_matrix{i,j} = [0 , 0];
            else
                diff = (j-i)* args; 
                formation_matrix{i, j} = diff; % Set connection from agent i to agent j
            end
        end
    end

elseif strcmp(type, 'poly')
    radius = args(1);
    angle_offset = args(2); % in radians
    formation_matrix = cell(numAgents, numAgents);

    % Compute positions of each agent on the circle
    positions = zeros(numAgents, 2);
    for i = 1:numAgents
        theta_i = angle_offset + (i - 1) * (2 * pi / numAgents);
        x = radius * cos(theta_i);
        y = radius * sin(theta_i);
        positions(i, :) = [x, y];
    end

    % Fill in the formation matrix
    for i = 1:numAgents
        for j = 1:numAgents
            if i == j
                formation_matrix{i, j} = [0, 0];
            else
                formation_matrix{i, j} = positions(j, :) - positions(i, :);
            end
        end
    end
end

end
