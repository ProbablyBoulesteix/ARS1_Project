% this is boilerplate code, but it need not be anything but generic for our
% purposes... unlike the animateMarkers function i simply need this to plot
% persistant lines for the various agent trajectories in 3D space
function plotAgentTrajectories(positions, startPositions, destinationPositions, numAgents)

    % Number of timesteps
    numSteps = size(positions{1},1); %should be equal to the number of timesteps

    % Preallocate arrays for trajectories
    trajectoriesX = zeros(numAgents, numSteps);
    trajectoriesY = zeros(numAgents, numSteps);

    % Extract trajectories
    for i = 1:numAgents
        agentpositions_i = positions{i};
        trajectoriesX(i, :) = agentpositions_i(:, 1); % X coordinates
        trajectoriesY(i, :) = agentpositions_i(:, 2); % Y coordinates

    end

    % Plot trajectories
    figure;
    hold on;
    colors = lines(numAgents); % Distinct colors for each agent

    for agentIdx = 1:numAgents
        % Plot trajectory line
        plot(trajectoriesX(agentIdx, :), trajectoriesY(agentIdx, :), ...
             'Color', colors(agentIdx, :), 'LineWidth', 2, 'DisplayName',sprintf('Bot %d trajectory', agentIdx) );

        % Plot start marker (circle with black edge)
        scatter(startPositions(agentIdx,1), startPositions(agentIdx,2), ...
                200, colors(agentIdx, :), 'o', 'filled', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 2, 'DisplayName',sprintf('Start %d', agentIdx));

        % Plot destination marker (cross with black edge)
        scatter(destinationPositions(agentIdx,1), destinationPositions(agentIdx,2), ...
                200, colors(agentIdx, :), '^', 'filled' ,'LineWidth', 2, ...
                'MarkerEdgeColor', 'k', 'DisplayName', sprintf('Dest %d', agentIdx));
    end

    xlabel('X Position');
    ylabel('Y Position');
    title('Agent Trajectories over time');
    
    % Legend
    legend( 'FontSize', 16);
    set(gca, 'FontSize', 18);

    % apply a bit of padding so min/max values aren't at edge of plot
    allPositions = cell2mat(positions');  

    
    xMin = min(allPositions(:,1));
    xMax = max(allPositions(:,1));
    yMin = min(allPositions(:,2));
    yMax = max(allPositions(:,2));

    % Define padding as fraction of range and apply
    xPad = 0.1 * (xMax - xMin);
    yPad = 0.1 * (yMax - yMin);
    xlim([xMin - xPad, xMax + xPad]);
    ylim([yMin - yPad, yMax + yPad]);


    grid on;
    %axis equal;
    hold off;
end