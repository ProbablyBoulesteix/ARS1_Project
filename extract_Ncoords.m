function pos = extract_Ncoords(swarmCoords_cell, agent_ID)
    % Returns a T x 2 matrix of [x, y] positions for agent_ID
    T = numel(swarmCoords_cell);
    pos = zeros(T, 2);  % Preallocate

    for t = 1:T
        coords_all = swarmCoords_cell{t};      % Nx2 matrix
        coords_agent = coords_all(agent_ID, :); % 1x2 vector
        pos(t, :) = coords_agent;              % Store in row t
    end
end