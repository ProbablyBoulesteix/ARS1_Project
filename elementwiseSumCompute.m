function  summed_component = elementwiseSumCompute(coords_actual, coords_desired, gains, G_connections, formation_sep)
% note: devised control law requires we evaluate a sum among two
% variables/iterators. We do the sum here then.
% coords (actual and desired) are 5x2 for 5 agents (Nx2), so the sum should
% also be a 5x2 matrix

outputarray = zeros(size(coords_desired, 1),2); %define a blank array for now
for i = 1:1:5
    %difference of errors, should not change
    error_i = coords_actual - coords_desired; %error/deviation for current bot based on measured/estimated position
    sum_i = zeros(1,2);
    for j = 1:1:5

        %difference of errors across j axis: to impose a formation, we'll
        %impose r_j* desired as r_j* = r_i* + d(i, j) = r_i* + (i-j)*formation_sep
        rj = coords_actual(i,: ) + [1, 0] %+ (i - j)*formation_sep;
        error_j = (coords_desired(j,: ) - rj)
        cross = gains(i,j) * G_connections(i,j)* (error_i(i,:) - error_j)
        sum_i = sum_i + cross
    end
    outputarray(i, :) = sum_i; % Store the computed sum for the current agent
    
end
summed_component = outputarray;
end

