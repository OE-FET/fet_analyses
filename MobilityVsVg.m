 function [Vg, mobSat, mobLin, data, pars] = MobilityVsVg(varargin)
%MOBILITYVSVG calculates the gate voltage dependent mobility
%
%   USAGE:
%   MOBILITYVSVG() - prompts user for data file and parameters
%   MOBILITYVSVG(data) - prompts user for parameters
%   MOBILITYVSVG(data, param) - calculates mobilities from given inputs
%   MOBILITYVSVG(data, param, 'plot', 0) - surpresses plot output
%
%   INPUT:
%   data        - structure containing transfer curve data from FETDataRead
%   data.x      - vector with gate voltage data for x.axis
%   data.Id     - matrix with drain current data
%   data.Vstep  - vector with drain voltage steps
%   param       - structure containing channel width W and length L, the
%                 deielectric thickness d and dielectric constant epsilon
% 
%   OUTPUT:
%   muSat  - saturation mobility in cm^2/Vs
%   muLin  - linear mobility in cm^2/Vs
%
%   Sam Schott, 06.10.2017
%   ss2151@cam.ac.uk
%

%% Input processing

% check if transfer data or file path is given as argument
if nargin > 0 && isstruct(varargin{1})
 data = varargin{1}; 
else
 data = FETDataRead; 
end

try
 pars = varargin{2}; 
catch
 pars.dummy = 0; 
end

% default to plot the data, unless otherwise specified
Plot = 1; 
for i = 1:nargin
    if ischar(varargin{i})
        if strcmp(varargin{i}, 'plot')
            Plot = varargin{i+1}; 
        end
    end
end

if strcmp(data.type, 'transfer') == 0
	error('Data has the wrong format. Please select a file with transfer characteristics.'); 
end

if isfield(pars, 'W') == 0
	pars.W = input('Please give the channel width W in m: '); 
end

if isfield(pars, 'L') == 0
    pars.L = input('Please give the channel length L in m: '); 
end

if isfield(pars, 'd') == 0
    pars.d = input('Please give the dielectric thickness d in m: '); 
end

if isfield(pars, 'epsilon') == 0
    pars.epsilon = input('Please give the dielectric constant epsilon of your dielectric: '); 
end

pars.C = 8.854E-12 * pars.epsilon/pars.d; % F/m^2

%% Process data
% determine the number of gate voltage points
nPoints = length(data.x)/2; 

% separate data of forward and backward sweep
Vg = data.x(1:nPoints, :); 

IdFWD = data.Id(1:nPoints, :); 
IdBWD = flipud(data.Id(nPoints + 1:2*nPoints, :)); 

% Take sqrt of drain current
SqrtIdFWD = sqrt(IdFWD); SqrtIdBWD = sqrt(IdBWD); 

% smooth data
sp = 3; 
SqrtIdFWD(:, 1) = smooth(SqrtIdFWD(:, 1), sp); SqrtIdFWD(:, 2) = smooth(SqrtIdFWD(:, 2), sp); 
SqrtIdBWD(:, 1) = smooth(SqrtIdBWD(:, 1), sp); SqrtIdBWD(:, 2) = smooth(SqrtIdBWD(:, 2), sp); 
IdFWD(:, 1) = smooth(IdFWD(:, 1), sp); IdFWD(:, 2) = smooth(IdFWD(:, 2), sp); 
IdBWD(:, 1) = smooth(IdBWD(:, 1), sp); IdBWD(:, 2) = smooth(IdBWD(:, 2), sp); 

% differentiate data
dV = mean(diff(Vg)); 

dSqrtFWD = abs(gradient(SqrtIdFWD(:, end), dV)); 
dSqrtBWD = abs(gradient(SqrtIdBWD(:, end), dV)); 

dLinFWD = abs(gradient(IdFWD(:, 1), dV)); 
dLinBWD = abs(gradient(IdBWD(:, 1), dV)); 


% calculate gate voltage dependent mobility in cm^2/Vs
mobSatFWD = 10000*2*dSqrtFWD.^2*pars.L/(pars.W*pars.C); 
mobSatBWD = 10000*2*dSqrtBWD.^2*pars.L/(pars.W*pars.C); 

VdLin = data.Vstep(1); 
mobLinFWD = 10000 * abs(pars.L/(pars.C*pars.W)*1/VdLin*dLinFWD); 
mobLinBWD = 10000 * abs(pars.L/(pars.C*pars.W)*1/VdLin*dLinBWD); 

% put data together
Vg = [Vg; flipud(Vg)]; 
mobSat = [mobSatFWD; flipud(mobSatBWD)]; 
mobLin = [mobLinFWD; flipud(mobLinBWD)]; 

if Plot == 1
    figure(1); plot(Vg, mobSat, 'o'); title('Saturation mobility'); 
    ylabel('Mobility (cm$^2$/Vs)'); xlabel('Gate Voltage (V)'); 
    figure(2); plot(Vg, mobLin, 'o'); title('Linear mobility'); 
    ylabel('Mobility (cm$^2$/Vs)'); xlabel('Gate Voltage (V)'); 
end

