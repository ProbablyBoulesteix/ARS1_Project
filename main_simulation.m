close all;
clear;

%% define basic params of config and swarm
% definining hard coded arrays of start and end positions here, might fix later
start_positions = [2,3; -1,-3;  -5,0; -8,-3; -11,-3];
stop_positions = [50, 0; 46, 0; 42, 0; 38, 0; 34, 0];

stop_positions2 = [50, 1000; 46, 1000; 42, 1000; 38, 1000; 34, 1000]; %define a far-off waypoint to make the robots move in a line with the y axis

%for experimentation, adding additionnal stop positions
stop_positions_A = [20,10; 16,10;  12,10; 8,10;  4, 10];
stop_positions_B = [20,-10; 16,-10;  12,-10; 8,-10;  4, -10];
stop_positions_C = [2,3; -2,3;  -6,3; -10,3;  -14, 3];

%destinations = {stop_positions; stop_positions_A; stop_positions_B;stop_positions_C; stop_positions; stop_positions2 } %add as many waypoints as required, specified as list
destinations = {stop_positions; stop_positions2 } %add as many waypoints as required, specified as list

% formation settings
formation_type = 'line'; %can be 'line' (platoon formation) or 'poly' (arranged around cicle)
formation_args = [-4, 0]; %refer to function for more info: for 'line', this is the [X, Y] vector seperating two adjacent (i and i+1) agents, while for poly it's [radius, offset]
% NOTE: if formation and destination arrangements don't match (ie robots
% asked to form a line but destinations are randomy placed, this will
% create a conflict

%define properties of swarm, should be coherent with number of entries in
%waypoint (eg waypoints should be Nx2 where N is the number of agents
numAgents = 5;

%scoring params
scoring_weights = [0.5, 0.5]; %determine how much to penalize being out of place (1) vs out of position (2) 
aggScoreThreshold = 0.1; %define score at which we change waypoints -> set to 0 if waypoint should never change, or simply dont specify a second stopover set in destinations

% gains for system, should have as many entries as agents
alphas = [1, 1, 1, 1, 1]*0.05; % for position control, where higher gain = more incentive to reach position (can overshoot or compromise formation)
coopGains = [1, 1, 1, 1, 1]*0.2 ; %for consensus/formation, control, where higher gain = more incentive to get into formation (can become unstable at higher values)


% asked to form a line but destinations are randomy placed, this will
% create a conflict

% define connection graph between agents in inbound terms (ie if agent 1
% recieves data from agents 2, 4 and 5 write [2,4,5]
connectionFrom1 = [1,2,3,4,5];
connectionFrom2 = [1,2,3,4,5];
connectionFrom3 = [1,2,3,4,5];
connectionFrom4 = [1,2,3,4,5];
connectionFrom5 = [1,2,3,4,5];

connectionLinks = {connectionFrom1, connectionFrom2, connectionFrom3, connectionFrom4,connectionFrom5}; %build list of all relations here: should have as many 
%connectionLinks = {[], [1], [1], [1],[3]}; 

%sim settings
simulationTime = 200; %number of timesteps to simulate
simulation_displayPeriod = 0.025; %the interval period used when updating the sim display...use larger values for slower motion (but motion looks less smooth)

% Additionnal artificial caps
maxControlAuthority_abs = 1; %defines a limit to the magntitude of the control input we can provide,  Set to Inf for no limit
limitMode = 'coupled' ; %two modes available, 'coupled' (limit total speed) and 'decoupled' (limit speed along each individual axis)

%% Intermediary setup
agentIDs = 1:1:numAgents;
if numel(connectionLinks) < numAgents
    for i = 1:(numAgents - numel(connectionLinks))
        connectionLinks{end + 1} = []; % Add new connections for the additional agents no specified
    end
end
if numel(connectionLinks) > numAgents
    connectionLinks = connectionLinks(1:numAgents) %remove excess agent relations if overspecified/Error
end
%defines thresholds for when we should switch waypoints
scorethresholds = {}
for n = 1:numel(destinations)-1
    scorethresholds{n} = aggScoreThreshold; % Append the threshold for the next destination
end
    scorethresholds{end+1} = 0; %append 0 to signify no switchover at final waypoint


% define connection matrix
G = zeros(numAgents, numAgents);
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

Delta = formation(formation_type, numAgents, formation_args); %creae formation matrix
%% simulation using just one robot
agent_coords = {}; %assume this is a T*N*2 cell where T is number of simulation timesteps and N is number of agents
controlInputs = {};
Jscore = {}; %scoring result for position and formation and agrgegate (Tx3)
% timestep counter
t = 1;

%choose which direction to set towards
destID = 1; %set the ID of the waypoint in the desctionation cell/vector


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
        delta = limitControlAuthority(delta, maxControlAuthority_abs, limitMode); %limit control input depending on robot power/limitd
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
%trajectories
agenttrajectories = {};
agentcontrols = {};

for n = 1:numAgents
    agenttraj_i = extract_Ncoords(agent_coords, n);
    agenttrajectories{n} = agenttraj_i;
end

for n = 1:numAgents
    agentcontrol_i = extract_Ncoords(controlInputs, n);
    agentcontrols{n} = agentcontrol_i;
end


% make system graph for display
systemGraph = drawDirectedGraph(G, false)

animateMarkers(agenttrajectories, simulation_displayPeriod, agentcontrols, Jscore, systemGraph);

%% draw directed graph of system
%drawDirectedGraph(G, true)