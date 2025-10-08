function summed_component = elementwiseSumCompute(coords_actual, coords_desired, gains, G_connections, formation_matrix)
%compute consensus term for robot swarm with N agents
N = size(coords_actual, 1); %number of robots
output_array = zeros(N, 2); % predefine output

for i = 1:N
    diff_i = zeros(1,2); 
    for j = 1:N
        %  compute difference between actual and desired positions
        ri_star = coords_desired(i,:);
        rj_star = coords_desired(j,:);
        ri = coords_actual(i,:);
        rj = coords_actual(j,:);
        %G_connections(i,j) *  gains(i)

        diff_ij = G_connections(i,j)  .* gains(i).* (ri + cell2mat(formation_matrix(i,j)) - rj);
        
        
        diff_i = diff_i+ diff_ij; % sum of consensus terms
    end
    %disp(class(diff_i))

    output_array(i,:) =  diff_i; % store result in cell
end

summed_component = output_array;
end