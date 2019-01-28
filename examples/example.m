%% standard FET parameters
epsilon = 2.05; % dielectric constant CYTOP
pars.W = 1e-3; % channel width in m
pars.L = 20*1e-6; % channel length in m
pars.d = 620*1e-9; % dielectric thickness in m


%% FI-ESR parameters
% epsilon = 3.6; % dielectric constant PMMA
% pars.W = 0.243; % channel width in m
% pars.L = 100*1e-6; % channel length in m
% pars.d = 500*1e-9; % dielectric thickness in m

%% Fit interval for mobility
pars.Vfit = 20; % voltage interval for the monility fit in V

%% calculate capacitance per unit area for the device architecture
epsilon_0 = 8.854187817*1e-12; % in F/m
pars.C = epsilon_0*epsilon/pars.d; % dielectric capacitance in F/m^2

%% mobility calculation
[mobSat, mobLin] = MobilityCalc(data, pars);
[vg, mobSatVg, mobLinVg] = MobilityVsVg(data, pars);