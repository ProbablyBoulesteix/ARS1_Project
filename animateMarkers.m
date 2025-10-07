function animateMarkersWithVectors(waypoints, dt, vectorDataList, Jscore, Dgraph)
% helper function designed to plot the position of all N bots and also
% their control input vectors, for illustration and debug purposes
%cobbled together from various bits of code


    numMarkers = numel(waypoints);
    numSteps = size(waypoints{1}, 1);
    numVectors = numel(vectorDataList);
    traceSteps = size(vectorDataList{1}, 1); 
    numScores = 3;


    % Tiled layout here
    hFig = figure('Name', 'Robot simulation illustration');
    plotlayout = tiledlayout(1, 2);
    infolayout = tiledlayout(plotlayout, 2, 1 , 'TileSpacing', 'compact'); %nested layout) 
    t = tiledlayout(plotlayout, 3, 1 , 'TileSpacing', 'compact'); %nested layout
    %t = tiledlayout(3, 1); % top row for bot X-Y, bottom row for input

    t.Layout.Tile = 1;
    infolayout.Layout.Tile = 2;

    title(t, 'Robot positionsk, control signals and loss metrics'); % Set 
    title(infolayout, 'System state and system graph'); % Set 

    %  top subplot is for robot positions
    ax1 = nexttile(t, 1);
    axes(ax1);
    %axis equal;
    grid on;
    hold on;
    %positions chosen to be large enough to accomodate all bot
    %destination/start positions
    xlim([-20, 60]); 
    ylim([-20, 20]);
    xlabel('X');
    ylabel('Y');
    title('XY robot positions');

    % Add vectors of control inputs here
    ax2 = nexttile(t, 2);
    axes(ax2);
    
    grid on;
    hold on;
    xlim([-4, 4]);
    ylim([-4, 4]);

    xlabel('Ux');
    ylabel('Uy');
    title('Control inputs to robots');

    %  bottom subplot is for score
    ax3 = nexttile(t, 3);
    axes(ax3);
    
    grid on;
    hold on;
%plot all scores for the swarm
    xlabel('Timestep');
    ylabel('Score');
    title('Losses');
    xlim([-10, numSteps])
    ylim([-10, numSteps])

    % Set up key press detection so matlab doesn't yell at me about
    % pressing STOP
    quitFlag = false;
    set(hFig, 'KeyPressFcn', @(src, event) keyCallback(event));

    % Define colors for all markers and vectors
    colors = lines(max(numMarkers, numVectors));
    %left pannel: plots 

    % Initialize marker handles
    markerHandles = gobjects(numMarkers, 1);
    for i = 1:numMarkers
        pos = waypoints{i}(1, :);
        markerHandles(i) = plot(ax1, pos(1), pos(2), 'o', ...
            'MarkerSize', 10, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'k');

        labelHandles(i) = text(ax1, pos(1) + 1, pos(2), sprintf('%d', i), ...
                'Color', colors(i,:), 'FontSize', 10, 'FontWeight', 'bold');

    end

        scoreHistory = zeros(0, 3); % Empty array to accumulate scores
        scoreHandles = gobjects(numScores, 1);
    for i = 1:numScores
        if i == 1
            scorename = 'Position loss';
        elseif i == 2
            scorename = 'Formation loss';
        elseif i == 3
            scorename = 'Aggregate/weighted loss';
        end
        scoreHandles(i) = plot(ax3, NaN, NaN, '-', ...
            'Color', colors(i,:), 'LineWidth', 4, 'DisplayName', scorename);
    end
        legend(ax3, 'Location', 'eastoutside');

    
    % info collumn on top right pannel
    infoAx = nexttile(infolayout, 1);
    
    %infoAx = nextile(infolayout, 2);
    axes(infoAx);
    axis off;
    %title(infoAx, 'Current state of robots and control inputs');
    infoTextHandle = text(infoAx, 0, 1, '', ...
         'FontSize', 16,   'FontName', 'Arial', ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'left');

        % graph
    graphAx = nexttile(infolayout, 2);
    axes(graphAx);
    axis off;
    title(graphAx, 'System graph');

    % Plot the graph into ax2
    nodeLabels = arrayfun(@(i) sprintf('Bot %d', i), 1:numMarkers, 'UniformOutput', false);
    hGraph = plot(graphAx, Dgraph, 'Layout', 'circle', ...
        'NodeLabel', nodeLabels, ... 
        'NodeColor', 'red', ...
        'EdgeColor', 'white', ...
        'ArrowSize', 16, ...
        'LineWidth', 3, ...
        'MarkerSize', 16);
    hGraph.Parent.Color = [0.1 0.1 0.1]



       



    
    


    % Initialize vector handles
    vectorHandles = gobjects(numVectors, 1);
    for i = 1:numVectors
        vectorHandles(i) = quiver(ax2, 0, 0, 0, 0, 0, ...
            'Color', colors(i,:), 'LineWidth', 2, 'MaxHeadSize', 2);
    end


    % main draw loop
    while ~quitFlag
        for step = 1:min(numSteps, traceSteps)
            % Update marker positions
            for i = 1:numMarkers
                pos = waypoints{i}(step, :);
                set(markerHandles(i), 'XData', pos(1), 'YData', pos(2));
                set(labelHandles(i), 'Position', [pos(1) + 1, pos(2)]);
            end

            % Update vector arrows
            
            for i = 1:numVectors
                vec = vectorDataList{i}(step, :);
                set(vectorHandles(i), 'UData', vec(1), 'VData', vec(2));
            end



        if step <= numel(Jscore) && ~isempty(Jscore{step})
            currentScores = Jscore{step}; % 1x3 matrix
            scoreHistory(end+1, :) = currentScores; % append to history

            for i = 1:3
                set(scoreHandles(i), 'XData', 1:size(scoreHistory, 1), ...
                             'YData', scoreHistory(:, i));
    end
end

        %now write info on right pannel
    %robot positions
    robotStr = '';
    for i = 1:numMarkers
        pos = waypoints{i}(step, :); %get XY coords
        robotStr = [robotStr, sprintf('Robot %d: (%.2f, %.2f)\n', i, pos(1), pos(2))];
    end


    % control signals
    controlStr = '';
    for i = 1:numVectors
        vec = vectorDataList{i}(step, :);
        controlStr = [controlStr, sprintf('U%d: (%.2f, %.2f)\n', i, vec(1), vec(2))];
    end


    % Format scores
    scoreStr = '';
    if step <= numel(Jscore) && ~isempty(Jscore{step})
        currentScores = Jscore{step};
        scoreStr = sprintf('Position: %.2f \nFormation: %.2f   \nWeighted: %.2f', ...
        currentScores(1), currentScores(2), currentScores(3));
    end



    % Update info box
    infoTextHandle.String = sprintf([
        '    Timestep  %d\n\n' ...
        '    ### Robot Positions ###\n%s\n' ...
        '    ### Control Inputs ###\n%s\n' ...
        '    ### Scores ###\n%s\n'], ...
        step, robotStr, controlStr, scoreStr);

    %draw directed graph
     infoTextHandle.String = sprintf([
        '    Timestep  %d\n\n' ...
        '    ### Robot Positions ###\n%s\n' ...
        '    ### Control Inputs ###\n%s\n' ...
        '    ### Scores ###\n%s\n'], ...
        step, robotStr, controlStr, scoreStr);



            drawnow;
            pause(dt);
            if quitFlag
                break;
            end
        end
    end

    function keyCallback(event)  %press k to quit
        if strcmp(event.Key, 'k')
            quitFlag = true;
            
        end
    end
end
