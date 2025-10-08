function newcontrol = limitControlAuthority(input, limit, mode )
%function limits how big of a control authority we can apply to the robots
%and returns either the original control input or the limited control input
if strcmp(mode, 'decoupled')
%naive, restricts control on x and y axis indepentently to [-max; +max]
    newcontrol = min(input, limit); 
    newcontrol = max(newcontrol, -limit); 
    %newcontrol = mat2cell(newcontrol;
end

if strcmp(mode, 'coupled')
    
%assume we have a motor driving each robot which can only move up to speed
%vmax: it can't go max speed in both directions, it's either full speed
%along x axis or y axis
for n = 1:size(input, 1) %for each robot
    commanded_input = input(n,:); %x-y coordinates
    %total commanded thrust using Pythagorus theorum
    commanded_thrust = commanded_input(1)^2 + commanded_input(2)^2;
    commanded_thrust = sqrt(commanded_thrust); % Calculate the total thrust

    newcontrol(n, :) = commanded_input; % Store the limited control input for each robot
    if commanded_input(1) == 0 %check for no movement along x to avoid divide by zero error
        thrustAngle = (pi/2) * commanded_input(2)/abs(commanded_input(2));% we need to preserve the sign
    else %otherwise, compute angle of travel
        thrustAngle = atan((commanded_input(2)/commanded_input(1))); %define the angle in which we're commading the robot, relative to x
    end

    %important: Atan is defined on +/- 90°, so we need to be able to check
    %for the other half-quadrant
    %the above works for any input Uy and any positive input Ux, as
    %negative Ux will be equivalent to changing the direction of Uy
    %we can fix this by checking for Ux < 0 and adding +180° to the above if true
    if commanded_input(1) <0 %i negative
        thrustAngle = thrustAngle + pi; %keep in mind this is all in radians
    end
    if commanded_thrust > limit
        %disp("Thrust limited")
        limited_input = [cos(thrustAngle), sin(thrustAngle)] * limit;
        newcontrol(n,:) = limited_input;
    else
        newcontrol(n,:) = commanded_input;
    end
    %newcontrol = mat2cell(newcontrol);
    %newcontrol(n, :) = limited_input; % Update the control input with the limited thrust
end
  

end

