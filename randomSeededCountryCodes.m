rng(1,'twister') % sets the random seed to the group 
load 'available_countries.mat' % loads the list of available countries to choose from
countryCodes = readtable('country_codes_V202401b.csv');
productCodes = readtable('product_codes_HS22_V202401b.csv');

idx = randsample(numel(available_countries),10); % creates an array with ten random numbers from 1 to the length of the available countries array
selectedCountries = available_countries(idx); % associates the 10 random numbers with the corresponding country codes


