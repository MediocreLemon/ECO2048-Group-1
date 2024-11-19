%TRACE Project
clear all
%1 - Randomly select 10 countries from the data provided
rng(1,'twister') % sets the random seed to the group number
load 'available_countries.mat' % loads the list of available countries to choose from
idx = randsample(numel(available_countries),10); % creates an array with ten random numbers from 1 to the length of the available countries array
selectedCountries = available_countries(idx); % associates the 10 random numbers with the corresponding country codes

%2 - Load the dataset corresponding to the randomly selected countries 
mainFile = "C:\Users\laube\Documents\MATLAB\ECO 2048\BACI_HS22_Y2022_V202401b.csv"; % load the main file containing the data to be sorted
ds = datastore(mainFile); % creates a datastore to sort through the data
adjustedData = []; % pre-allocated a matrix to hold the data for the countries selected
ds.SelectedVariableNames = {'i', 'j', 'k', 'v'}; % holds the names of the variables where data is to be taken from the main file
while hasdata(ds) % while there is unread data in the datastore
    segment = read(ds); % reads the datastore
    isSelected = ismember(segment.i,selectedCountries) & ismember(segment.j,selectedCountries); % holds data where the I and J match something from the list of seleted countries
    adjustedSegment = segment(isSelected,:);
    adjustedData = [adjustedData; adjustedSegment]; %#ok<AGROW> % fills the adjustedData matrix with data stored under i,j,k, and v for the selected countries
end

%4 obtain the total value of V for each pair of nations

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

%5 build a matrix to determine which countries trade with the others
% ignore countries trading with themselves
