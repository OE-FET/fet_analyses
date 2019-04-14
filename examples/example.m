%% standard FET parameters
epsilon = 2.05; % dielectric constant CYTOP
epsilon_0 = 8.854187817*1e-12; % in F/m

pars.C = epsilon_0*epsilon/pars.d; % dielectric capacitance in F/m^2
pars.W = 1e-3; % channel width in m
pars.L = 20*1e-6; % channel length in m
pars.d = 620*1e-9; % dielectric thickness in m

%% calculate capacitance per unit area for the device architecture

%% read and plot transfer curve data
data = FETDataRead();
TransferDataPlot(data);

%% calculate mobility
[vg, mobSatVg, mobLinVg] = MobilityVsVg(data, pars);
