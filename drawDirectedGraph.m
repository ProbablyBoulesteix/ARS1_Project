function graph = drawDirectedGraph(G, display)
    % G: NxN connection matrix where G(i,j) = 1 means node i sends to node j

    N = size(G, 1); % Number of nodes

    % Create a directed graph object
    DG = digraph(G'); %taking the transpose to make arrows go the right direction

    % Generate node labels
    nodeLabels = arrayfun(@(i) sprintf('Bot %d', i), 1:N, 'UniformOutput', false);

    if display
    %Plot the graph
    figure;
    h = plot(DG, 'Layout', 'circle', ...
        'NodeLabel', nodeLabels, ...        
        'EdgeColor', 'white', ...
        'NodeColor', 'red', ...
        'ArrowSize', 15, ...
        'LineWidth', 4, ...
        'MarkerSize', 16);
    h.Parent.Color = [0.1 0.1 0.1]; %using light background so the colors pop, change as needed
    title('Directed Graph of robot formation');
    end
    graph  = DG;

end