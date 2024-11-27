%TRACE Project
clear all
%% 1 - Randomly select 10 countries from the data provided
rng(1,'twister') % sets the random seed to the group number
load 'available_countries.mat' % loads the list of available countries to choose from
idx = randsample(numel(available_countries),10); % creates an array with ten random numbers from 1 to the length of the available countries array
selectedCountries = available_countries(idx); % associates the 10 random numbers with the corresponding country codes

%% 2 - Load the dataset corresponding to the randomly selected countries 
mainFile = "C:\Users\Jamie\Documents\Uni Work\MATLAB\Matlab Work\BACI_HS22_Y2022_V202401b.csv"; % load the main file containing the data to be sorted
ds = datastore(mainFile); % creates a datastore to sort through the data
adjustedData = []; % pre-allocated a matrix to hold the data for the countries selected
ds.SelectedVariableNames = {'i', 'j', 'k', 'v'}; % holds the names of the variables where data is to be taken from the main file
while hasdata(ds) % while there is unread data in the datastore
    segment = read(ds); % reads the datastore
    isSelected = ismember(segment.i,selectedCountries) & ismember(segment.j,selectedCountries); % holds data where the I and J match something from the list of seleted countries
    adjustedSegment = segment(isSelected,:);
    adjustedData = [adjustedData; adjustedSegment]; %#ok<AGROW> % fills the adjustedData matrix with data stored under i,j,k, and v for the selected countries
end

%% 4 obtain the total value of V for each pair of nations

% Create a table to store the data
tradeData = table(adjustedData.i, adjustedData.j, adjustedData.k, adjustedData.v, 'VariableNames', {'Origin', 'Destination', 'Product Code', 'Value'}); 
%technically redudant, but keeps the variable seperate and introduces
%cleaner variable names
 
% create a matrix of all unique pairs of exporters and importers
pairs = unique([adjustedData.i, adjustedData.j], 'rows');

% pre-initialize a result matrix
tradeValueResult = zeros(size(pairs, 1), 3);

for k = 1:size(pairs, 1)
    origin = pairs(k, 1); %origin nation is the first column
    destination = pairs(k, 2); %destination nation is the second column
    
    % Find all rows corresponding to this pair
    pairRow = tradeData.Origin == origin & tradeData.Destination == destination;
    
    % Sum the trade values for this pair
    totalValue = sum(tradeData.Value(pairRow));
    
    % Store the result
    tradeValueResult(k, :) = [origin, destination, totalValue];
end

%% 5 build a matrix to determine which countries trade with the others
% ignore countries trading with themselves
nCountries = length(selectedCountries); % Length = 10 (selectedCountries)

codeToIndex = containers.Map(selectedCountries, 1:nCountries);

A = zeros(nCountries, nCountries); %creates a 10x10 matrix of zeros

for k = 1:size(pairs, 1)
    original_i = pairs(k, 1);  % Exporting country code
    original_j = pairs(k, 2);  % Importing country code
    
    % Map to matrix indices
    i = codeToIndex(original_i);
    j = codeToIndex(original_j);
    
    if i ~= j  % Ensure no self-trade is counted
        A(i, j) = 0;
    end
end

disp(A) %Displays A, a 10x10 matrix representing trade realtionships between selected countries 

%% 7 - Plot graph corresponding to A

G = digraph(A); %creates graph object

figure;
p = plot(G, 'layout', 'force', 'NodeLabel',selectedCountries);
% Node = Selected Countries (in order of selection, i.e 258 = node 1)
% Edge represents the in-degree and out-degree for each node (import,export)

% graph customisation
title('Trade Connectivity Graph')
p.NodeColor = 'k'; % sets node colour (country code) to 'black'
p.MarkerSize = 6; % Sets size of the NodeMarker
p.EdgeColor = 'b'; % Sets the colour of the edge to 'blue'


%% 8 calculating out-degree

OutDegree = sum(A, 2); % calculates the out-degree for exporting countries
% i.e. i = 258, out-degree = 5 means exports to 5/9 other countries in the model

