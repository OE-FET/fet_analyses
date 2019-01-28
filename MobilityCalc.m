function [muSat, muLin] = MobilityCalc(varargin)
% MOBILITYCALC calculates the mobility in the saturation regime by a linear
% fit to sqrt(Isd) over the last 20V of the data range.
%
%   CALL AS:
%   mobilityCalc() - prompts user for data file and parameters
%   mobilityCalc(data) - prompts user for parameters
%   mobilityCalc(data, param) - calculates mobilities from given inputs
%   mobilityCalc(data, param, 'plot',1) - plots fit curves
%
%   INPUT:
%   data.x - vector with gate voltage data for x.axis
%   data.Id - matrix with drain current data
%   data.Vstep - vector with drain voltage steps
%   param - structure containing channel width W, length L, dielectric
%   thickness d and dielectric constant epsilon
%   
%   OUTPUT:
%   muSat - saturation mobility in cm^2/Vs
%   muLin - linear mobility in cm^2/Vs
%   Vth - threshold voltage in V
%
%   Sam Schott, 06.10.2017
%   ss2151@cam.ac.uk
%

%% check which input data is given
if nargin > 0 && isstruct(varargin{1})
    data=varargin{1};
else
    data=FETDataRead;
    if isempty(data)
        return;
    end
end
if nargin > 1 && isstruct(varargin{2})
    par=varargin{2};
else
    par.dummy=0;
end
Plot = 1;
for i=1:nargin
    if ischar(varargin{i})
        if strcmp(varargin{i},'plot')
            Plot=varargin{i+1};
        end
    end
end

if strcmp(data.type,'transfer')==0
    error('Data has the wrong format. Please select a file with transfer characteristics.');
end

if isfield(par,'W')==0
    par.W=input('Please give the channel width W in m: ');
end
if isfield(par,'L')==0
    par.L=input('Please give the channel length L in m: ');
end
if isfield(par,'C')==0
    par.C=input('Please give the dielectric capacitance per unit area in F/m^2: ');
end
if isfield(par,'Vfit')==0
    par.Vfit=input('Please give the voltage interval for the monility fit in V: ');
end


%% Process data
% determine the number of gate voltage points
nPoints=length(data.x)/2;
data.Id = abs(data.Id); data.Ig = abs(data.Ig);

% Average data over forward and backward sweep
VgAVG=(data.x(1:nPoints,:)+flipud(data.x(nPoints+1:2*nPoints,:)))./2;
IdAVG=(data.Id(1:nPoints,:)+flipud(data.Id(nPoints+1:2*nPoints,:)))./2;

% Take sqrt of drain current
SqrtIdAVG=sqrt(IdAVG);
SqrtId=sqrt(abs(data.Id));

%% Calculate saturation mobility
if par.Vfit > max(abs(VgAVG))
    error('Please choose a fit interval that is smaller than the maximum gate voltage.');
end
% find beginning and end of fit interval
StartN = nPoints - sum( abs(VgAVG)>=(max(abs(VgAVG))-par.Vfit) );

% linear fit to SqrtId
fitpars = polyfit(VgAVG(StartN:end),SqrtIdAVG(StartN:end,2),1);

% calculate saturation mobility in cm^2/Vs form slope of SqrtId
muSat=2*10000*par.L*fitpars(1)^2/(par.W*par.C);

% plot fit curve
if Plot==1
    figure(1);
    plot(VgAVG,fitpars(1)*VgAVG+fitpars(2),':k');hold on;
    plot(data.x,SqrtId);axis([min(data.x) max(data.x) 0 1.1*max(max(SqrtId))]);
    hold off;
end

%% Calculate linear mobility
FitNumber=nPoints-sum(abs(VgAVG)>=max(abs(VgAVG))-par.Vfit); % determine interval of curve for linear fit

VdLin=data.Vstep(1);
fitpars = polyfit(VgAVG(FitNumber:end),IdAVG(FitNumber:end,1),1);
muLin=abs(10000*par.L/(par.C*par.W)*1/VdLin*fitpars(1));%in cm^2/Vs

% plot fit curve
if Plot==1
    figure(2);
    plot(VgAVG,IdAVG);
    hold on;plot(VgAVG,fitpars(1)*VgAVG+fitpars(2),':k');
    axis([min(data.x) max(data.x) 0 max(max(IdAVG))]);
    hold off;
end

end
