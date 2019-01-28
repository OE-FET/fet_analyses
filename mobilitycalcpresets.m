%% standard FET parameters
pars.W = 1e-3; % channel width in m
pars.L = 20*1e-6; % channel length in m
pars.d = 620*1e-9; % dielectric thickness in m
epsilon = 2.05; % dielectric constant CYTOP

%% FI-ESR parameters
% pars.C = 4.7e-4; % for CTYOP / Al2O3 bilayer
pars.W = 0.243; % channel width in m
pars.L = 100*1e-6; % channel length in m
pars.d = 620*1e-9; % dielectric thickness in m
epsilon = 3.6; % dielectric constant PMMA

%% FRFET / CYTOP stack parameters
% pars.C = 4.7e-4; % for CTYOP / Al2O3 bilayer
% pars.C = 4*1E-04; % in F/m^2

%% Fit interval for mobility
pars.Vfit = 20; % voltage interval for the monility fit in V

%% calculate capacitance per unit area for the device architecture
epsilon_0 = 8.854187817*1e-12; % in F/m
pars.C = epsilon_0*epsilon/pars.d; % in F/m^2

%% mobility calculation
[mobSat, mobLin] = MobilityCalc(data, pars);
[vg, mobSatVg, mobLinVg] = MobilityVsVg(data, pars);