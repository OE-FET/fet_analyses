function TransferDataPlot(data)
% TRANSFERDATAPLOT Plots given FET transfer curve data on logarithmic plot
%
%   Promts user for file with data if no input is given.
%
%   Sam Schott, 06.10.2017
%   ss2151@cam.ac.uk
%

if nargin == 0
    data = FETDataRead;
    % handle gracefully if no file is selected
    if isempty(data)
        return;
    end
end

% take absolute vales of currents
data.Id = abs(data.Id);
try
    data.Is = abs(data.Is);
catch
    data.Is = abs(data.Id);
end
data.Ig = abs(data.Ig);
% check if data matches expected transfer curve format
if strcmp(data.type, 'transfer') == 0
    error('Data has the wrong format. Please select a file with transfer characteristics.');
end

% Plot transfer curves
fhandle = figure(); % open new figure

hs = ishold;

plot(data.x, data.Id, '-');
figure(fhandle); hold on;
plot(data.x, data.Is ,'-');
figure(fhandle); hold on;
plot(data.x, data.Ig, '--');
set(gca, 'YScale', 'log'); % set log scale

% create plot legend
for j=1:length(data.Vstep)
    legStr{j} = ['Id (Vd = ', num2str(data.Vstep(j)), 'V)'];
    legStr{j+length(data.Vstep)} = ['Is (Vd = ', num2str(data.Vstep(j)), 'V)'];
    legStr{j+2*length(data.Vstep)} = ['Ig (Vd = ', num2str(data.Vstep(j)), 'V)'];
end
legend(legStr, 'Location', 'southwest');
title('Transfer characteristics');
xlabel('Gate Voltage (V)');
ylabel('Drain Current (A)');
set(gca, 'YMinorTick', 'on');

xlim([min(data.x) max(data.x)]);

%% Create arrows for hysteresis
% position of arrow
x1 = data.x(round(0.7*length(data.x)/2));
x2 = data.x(round(0.75*length(data.x)/2));

% check for direction of hysteresis loop
slice = data.Id(data.x<-20, end);
fwd_sweep = slice(1:end/2);
bwd_sweep = flipud(slice(end/2+1:end));

if mean(fwd_sweep - bwd_sweep) > 0
    offset = 0.02;
else
    offset = -0.02;
end

% forward arrow
p1 = [x1 data.Id(data.x(1:end/2)==x1, end)];
p2 = [x2 data.Id(data.x(1:end/2)==x2, end)];
[p1nx, p1ny] = normalize_coordinate(p1(1), p1(2), get(gca, 'Position'), xlim, ylim, 0, 1);
[p2nx, p2ny] = normalize_coordinate(p2(1), p2(2), get(gca, 'Position'), xlim, ylim, 0, 1);

annotation(fhandle, 'arrow', [p1nx p2nx], [p1ny+offset p2ny+offset]);

% backward arrow
p1 = p1 + [0 diff(data.Id(data.x==x1, end))];
p2 = p2 + [0 diff(data.Id(data.x==x2, end))];
[p1nx, p1ny] = normalize_coordinate(p1(1), p1(2), get(gca, 'Position'), xlim, ylim, 0, 1);
[p2nx, p2ny] = normalize_coordinate(p2(1), p2(2), get(gca, 'Position'), xlim, ylim, 0, 1);

annotation(fhandle, 'arrow', [p2nx p1nx], [p2ny-offset p1ny-offset]);


%% Plot sqrt of saturation curve
fhandle = figure(); % open new figure
SqrtSat = sqrt(data.Is(:, end)); hold on;
plot(data.x, SqrtSat, '-');
title('Transfer characteristics');
xlabel('Gate Voltage (V)');
ylabel('Sqrt of Drain Current (A^{1/2})');
legend('Saturation current', 'Location', 'southwest');
box on;

% forward arrow
p1 = [x1 SqrtSat(data.x(1:end/2)==x1)];
p2 = [x2 SqrtSat(data.x(1:end/2)==x2)];
[p1nx, p1ny] = normalize_coordinate(p1(1), p1(2), get(gca, 'Position'), xlim, ylim, 0, 0);
[p2nx, p2ny] = normalize_coordinate(p2(1), p2(2), get(gca, 'Position'), xlim, ylim, 0, 0);

annotation(fhandle, 'arrow', [p1nx p2nx], [p1ny+offset p2ny+offset]);

% backward arrow
p1 = p1 + [0 diff(SqrtSat(data.x==x1))];
p2 = p2 + [0 diff(SqrtSat(data.x==x2))];
[p1nx,  p1ny] = normalize_coordinate(p1(1), p1(2), get(gca, 'Position'), xlim, ylim, 0, 0);
[p2nx, p2ny] = normalize_coordinate(p2(1), p2(2), get(gca, 'Position'), xlim, ylim, 0, 0);

annotation(fhandle, 'arrow', [p2nx p1nx], [p2ny-offset p1ny-offset]);

if hs == 0 
    hold off;
end

end

