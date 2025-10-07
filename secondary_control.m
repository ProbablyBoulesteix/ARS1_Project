close all;
clear;

%% define basic params of config
% definining hard coded arrays of start and end positions here, might fix later
start_positions = [2,3; -1,-3;  -5,0; -8,-3;  -11,-3];
stop_positions = [50, 0; 46, 0; 42, 0; 38, 0; 34, 0];
stop_positions2 = [50, 50; 46, 50; 42, 50; 38, 50; 34, 50];

destinations = {stop_positions; stop_positions2} %add as many waypoints as required


distance_formation_desired = [-4,0];

%define properties of swarm
numAagents = 5;
agentIDs = 1:1:numAagents;
swarmLeaderID = 1; % ID of leading bot

%scoring params
scoring_weights = [0.5, 0.5]; %determine how much to penalize being out of position (2) vs out of place (1)
aggScoreThreshold = 0.01; %define score at which we change waypoints -> set to 0 if waypoint should never change, or simply dont specify a second stopover set in destinations

simulationTime = 2000; %number of timesteps to simulate


%% define swarm parameters 
% define connection graph between agents in inbound terms (ie if agent 1
% recieves data from agents 2, 4 and 5 write [2,4,5]
connectionTo1 = [2,3,4,5];
connectionTo2 = [1,3,4,5];
connectionTo3 = [1,2,4,5];
connectionTo4 = [1,2,3,5];
connectionTo5 = [1,2,3,4];
connectionLinks = {connectionTo1, connectionTo2, connectionTo3, connectionTo4, connectionTo5}; %build list of all relations here

%set gains here (tune later)
alphas = [1, 1, 1, 1, 1]*0.005;
coopGains = [1, 1, 1, 1, 1] * 0.3 %use unity gain to start


% define connection matrix
G = zeros(numAagents, numAagents);
for i = agentIDs
    sources = connectionLinks{i};
    %now iter through each source and set the connection coef to 1. sanity
    %check for matches beween i and j too
    for j = sources
        if i == j
            G(i,j) = 0;
        else
            G(i, j) = 1; % Set connection from agent i to agent j
        end
    end
end

% let's define a formation matrix
Delta = cell(5,5);
for i = agentIDs
        %now iter through each source and set the connection coef to 1. sanity
    %check for matches beween i and j too
    for j = agentIDs
        if i == j
            Delta{i,j} = [0 , 0];
        else
            diff = (j-i)* distance_formation_desired;
            Delta{i, j} = diff; % Set connection from agent i to agent j
        end
    end
end

%% simulation using just one robot
agent_coords = {}; %assume this is a T*N*2 cell where T is number of simulation timesteps and N is number of agents
controlInputs = {};
Jscore = {}; %scoring result for position and formation and agrgegate (Tx3)
% timestep counter
t = 1;

%choose which direction to set towards
destID = 1; %set the ID of the waypoint in the desctionation cell/vector
scorethresholds = {aggScoreThreshold, 0}; %append 0 to signify no switchover at final waypoint

%loop here
while true
    if t == 1 %add starting positions if at beginning of sim loop
        agent_coords{t} = start_positions;
        controlInputs{t} = start_positions * 0; %use a zero vector for control inputs
        Jscore{t} = constraintEquation(agent_coords{t},destinations{destID}, Delta,scoring_weights);
        t = t + 1;
    else
    %increment here
        %agent_coords{t - 1}
        delta = controlLaw(agent_coords{t - 1}, destinations{destID}, alphas, coopGains, G, Delta);
        controlInputs{t} = delta;
        agent_coords{t} = agent_coords{t - 1} + delta;
        Jscore{t} = constraintEquation(agent_coords{t},destinations{destID}, Delta, scoring_weights );
        t = t + 1;
    end
    if Jscore{t-1}(3) < scorethresholds{destID}
        destID = destID +1;

    end

    % Check stopping condition (example: stop after 100 steps)
    if t > simulationTime  % Replace with your actual condition
        break;
    end
end %FIXME: issue where scoring doesnt change when waypoint changes

%%
agenttraj1 = extract_Ncoords(agent_coords, 1);
agenttraj2 = extract_Ncoords(agent_coords, 2);
agenttraj3 = extract_Ncoords(agent_coords, 3);
agenttraj4 = extract_Ncoords(agent_coords, 4);
agenttraj5 = extract_Ncoords(agent_coords, 5);

vectorScalingFactor = 20;
agent1control = extract_Ncoords(controlInputs, 1) * vectorScalingFactor;
agent2control = extract_Ncoords(controlInputs, 2) * vectorScalingFactor;
agent3control = extract_Ncoords(controlInputs, 3) * vectorScalingFactor;
agent4control = extract_Ncoords(controlInputs, 4) * vectorScalingFactor;
agent5control = extract_Ncoords(controlInputs, 5) * vectorScalingFactor;

animateMarkers({agenttraj1, agenttraj2, agenttraj3, agenttraj4, agenttraj5}, 0.005, {agent1control, agent2control, agent3control, agent4control, agent5control}, Jscore);
