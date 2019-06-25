function [fhandle] = OutputDataPlot(data)
% OUTPUTDATAPLOT Plots given FET output curve data on logarithmic plot
%
%   Promts user for file with data if no input is given.
%
%   Sam Schott, 06.10.2017
%   ss2151@cam.ac.uk
%

%% INPUT processing
% check if data structure is given, otherwise ask for file
if nargin==0
    data = FETDataRead;
    % handle gracefully if no file is selected
    if isempty(data)
        return;
    end
end
% report error if data does not match expected output curve format
if strcmp(data.type,'output')==0
    error('Data has the wrong format. Please select a file with output characteristics.');
end
% take absulute values of all currents
data.Id = abs(data.Id); data.Ig = abs(data.Ig);

% Plot output curves
fhandle = figure(); % create new figure
plot(data.x, data.Id, '-');
hold on;
plot(data.x, data.Ig, '--');
hold off;

% create plot legend
for j = 1:length(data.Vstep)
    legStr{j} = ['Id (Vg = ', num2str(data.Vstep(j)),'V)'];
    %legStr{j+length(data.Vstep)} = ['Ig (Vg = ',num2str(data.Vstep(j)),'V)'];
end
legend(legStr,'Location','southwest');
title('Output characteristics');
xlabel('Source-Drain Voltage (V)');
ylabel('Drain Current (A)');

xlim([min(data.x) max(data.x)]);

%% Create arrows for hysteresis
% position of arrow
x1 = data.x(round(0.7*length(data.x)/2));
x2 = data.x(round(0.75*length(data.x)/2));

% check for direction of hysteresis loop
slice = data.Id(data.x<-20,end);
fwd_sweep = slice(1:end/2);
bwd_sweep = flipud(slice(end/2+1:end));

if mean(fwd_sweep - bwd_sweep) > 0
    offset = 0.02;
else
    offset = -0.02;
end

% forward arrow
p1 = [x1 data.Id(data.x(1:end/2)==x1,end)];
p2 = [x2 data.Id(data.x(1:end/2)==x2,end)];
[p1nx, p1ny] = normalize_coordinate(p1(1),p1(2),get(gca, 'Position'),xlim,ylim,0,0);
[p2nx, p2ny] = normalize_coordinate(p2(1),p2(2),get(gca, 'Position'),xlim,ylim,0,0);

annotation(fhandle,'arrow',[p1nx p2nx],[p1ny+offset p2ny+offset]);

% backward arrow
p1 = p1 + [0 diff(data.Id(data.x==x1,end))];
p2 = p2 + [0 diff(data.Id(data.x==x2,end))];
[p1nx, p1ny] = normalize_coordinate(p1(1),p1(2),get(gca, 'Position'),xlim,ylim,0,0);
[p2nx, p2ny] = normalize_coordinate(p2(1),p2(2),get(gca, 'Position'),xlim,ylim,0,0);

annotation(fhandle,'arrow',[p2nx p1nx],[p2ny-offset p1ny-offset]);

hold off;
end

