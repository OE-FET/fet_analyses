%% FET analyses: plots data and extracts mobilities
%
%   Sam Schott, 06.10.2017
%   ss2151@cam.ac.uk
%

%% Set FET parameters
% param.W=1000e-6; param.L=20e-6; % for standard FET, values in m
par.W = 24.3e-2; par.L = 100e-6;    % for FI-ESR devices, values in m
par.d = 520e-9;                     % in m (480 nm for CYTOP, 300 nm for SiO2, 520 for PMMA)
par.epsilon = 2.1;                  % CYTOP: 2.1, PMMA: 3.6, SiO2: 3.9
par.C = 8.854E-12 * par.epsilon/par.d; % F/m^2

%% Get files
%------------------------
[FileName, PathName] = uigetfile('*.txt', 'Select transfer data file(s)', 'MultiSelect', 'on');
Path2File = fullfile(PathName, FileName);

% determine number of selected files
if iscell(FileName)==0
    nFiles=1;
elseif iscell(FileName)==1
    nFiles=length(FileName);
end
% preallocate memory
% mobSat = zeros(142, length(nFiles));
% mobLin = zeros(142, length(nFiles));

% calculate mobilities from files and plot transfer curves
for i = 3:nFiles
    
    if nFiles==1
        path2file = Path2File;
    else
        path2file = Path2File{i};
    end
    
    data = FETDataRead(path2file);
    
    try
        [startIndex, endIndex] = regexp(path2file, '[0-9]+K');
        T(i) = str2double( path2file(startIndex:endIndex-1) );
    catch
        disp('No temperature string found in file name.');
    end
    
    if strcmp(data.Type, 'transfer')==0
        error('Data has the wrong format. Please select a file with transfer characteristics.');
    end
    [Vg, mobSat(:,i), mobLin(:,i)] = MobilityVsVg(data, par);
    TransferDataPlot(data);
end

