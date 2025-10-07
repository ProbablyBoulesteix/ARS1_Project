function graph = drawDirectedGraph(G)
    % G: NxN connection matrix where G(i,j) = 1 means node i sends to node j

    N = size(G, 1); % Number of nodes

    % Create a directed graph object
    DG = digraph(G');

    % Generate node labels
    nodeLabels = arrayfun(@(i) sprintf('Node %d', i), 1:N, 'UniformOutput', false);

    % Plot the graph
    %figure;
    %h = plot(DG, 'Layout', 'circle', ...
        %'NodeLabel', nodeLabels, ...        
       % 'EdgeColor', 'red', ...
        %'NodeColor', 'blue', ...
      %  'ArrowSize', 15, ...
     %   'LineWidth', 3, ...
      %  'MarkerSize', 16);
   % h.Parent.Color = [0.1 0.1 0.1]; % light blue background
    %title('Directed Graph of Node Connections');
    graph  = DG;
end