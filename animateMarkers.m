function animateMarkers(waypoints, dt)
    % waypoints: cell array of Nx2 matrices (X, Y) for each marker
    % dt: time delay between updates (in seconds)

    numMarkers = numel(waypoints);

    if iscell(waypoints)
        numSteps = size(waypoints{1}, 1);
    else
        numSteps = size(waypoints);
    end
    

    % Create figure
    hFig = figure('Name', '2D Marker Animation');
    axis equal;
    grid on;
    hold on;
    xlim([-20, 60]);
    ylim([-15, 15]);
    xlabel('X');
    ylabel('Y');

    % Set up key press detection
    quitFlag = false;
    set(hFig, 'KeyPressFcn', @(src, event) keyCallback(event));

    % Define colors
    colors = lines(numMarkers);

    % Initialize marker handles
    markerHandles = gobjects(numMarkers, 1);
    for i = 1:numMarkers
        pos = waypoints{i}(1, :);
        markerHandles(i) = plot(pos(1), pos(2), 'o', ...
            'MarkerSize', 10, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'k');
    end

    % Animation loop
    while ~quitFlag
        for step = 1:numSteps
            for i = 1:numMarkers
                pos = waypoints{i}(step, :);
                set(markerHandles(i), 'XData', pos(1), 'YData', pos(2));
            end
            drawnow;
            pause(dt);
            if quitFlag
                break;
            end
        end
    end

    function keyCallback(event)
        if strcmp(event.Key, 'k')
            quitFlag = true;
            disp('Animation stopped by user.');
        end
    end
end