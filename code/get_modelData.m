function data = get_modelData
%GET_MODELDATA Extended model for a longer battery lifetime
%
% INPUTS
% n/a
%
% OUTPUTS
% data              A structure containing all the model parameters.
%
% Copyright (c) 2016, The Chancellor, Masters and Scholars of the University 
% of Oxford, and the 'Spectral li-ion SPM' Developers.
% See the licence file LICENCE.txt for more information.

%% Cell capacity [A.h]
data.C_nom = 2.2;

%% CONSTANTS
data.R = 8.314;                     % Gas constant [J.K-1.mol-1]
data.F = 96487;                     % Faraday constant [C.mol-1]
data.T_ref = 25 + 273.15;           % Reference temperature [K]

%% CURRENT COLLECTOR
data.Rc = 40e-4;                    % Current collector resistance [ohm.m2]
data.R_0 = 40e-4;

%% BATTERY GEOMETRY
data.thick1 = 73.50e-6;             % Thickness of anode [m]
data.thick2 = 25.00e-6;             % Thickness of separator [m]
data.thick3 = 70.00e-6;             % Thickness of cathode [m]
data.L = data.thick1 + data.thick2 + data.thick3;  % Thickness of the cell [m]

% Electrode active surface area [m2] (assumed equal for anode and cathode)
data.As = 0.0982;

%% ACTIVE POROUS MATERIAL
% Solid particles of the electrodes
data.Rs1 = 12.5e-6;                 % Anode solid particles' radius [m]
data.Rs3 = 8.5e-6;                  % Cathode solid particles' radius [m]

% Volume fraction of active material [-]
data.eps1s = 0.5052;                % anode
data.eps3s = 0.5500;                % cathode

% Specific interfacial surface area in porous electrodes [m2/m3]
data.as1 = (3 * data.eps1s) / data.Rs1; % anode   
data.as3 = (3 * data.eps3s) / data.Rs3; % cathode

% Max Solid phase concentration [mol.m-3]
data.cs1_max = 30556;           
data.cs3_max = 51555;

% Stoichiometry limits [-]
data.x1_soc0 = 0.0068;              % at 0% soc in anode
data.x1_soc1 = 0.7560;              % at 100% soc in anode
data.y3_soc0 = 0.8933;              % at 0% soc in cathode
data.y3_soc1 = 0.4650;              % at 100% soc in cathode

%% DIFFUSION COEFFICIENTS
data.Ds1_ref = 3.9e-14;             % Anode diffusion coeff @ ref temperature [m2.s-1]
data.Ds3_ref = 1.0e-14;             % Cathode diffusion coeff @ ref temperature [m2.s-1]

data.Ea_Ds1 = 50e3;                 % Higher activation energy for slower diffusion in anode [J/mol]
data.Ea_Ds3 = 45e3;                 % Higher activation energy for slower diffusion in cathode [J/mol]

%% LI INTERCALATION KINETICS (Butler-Volmer equation)
data.k1_ref = 1.764e-11;
data.k3_ref = 6.667e-11;

data.Ea_k1 = 30e3;                  % Higher activation energy for slower reaction in anode [J/mol]
data.Ea_k3 = 70e3;                  % Higher activation energy for slower reaction in cathode [J/mol]

data.ce_avg = 1.0e3;                % Average electrolyte concentration

%% THERMAL MODEL PARAMETERS WITH CONVECTION BOUNDARY CONDITIONS
data.Cp = 750;                       % Heat capacity [J/kg/K]
data.rho = 1626;                     % Density [kg/m3]

data.height = 65e-3;                 % 18650 height [m]
data.diam = 18e-3;                   % 18650 diameter [m]

% Surface area to volume ratio for an 18650 cell [m-1]
data.SA_V = 4 * (1 + data.diam / data.height / 2) / data.diam;
% Volume of the cell
data.Vc = pi * (data.diam / 2)^2 * data.height;

% Convective boundary condition
data.h = 30;                         % Convection heat transfer coefficient [W/m2/K]
data.T_amb = 25 + 273.15;            % Ambient temperature [K]

%% LIFE EXTENDING PARAMETERS
% Further reduced the degradation rates to extend battery life
data.capacity_fade_rate = 0.0001;     % Even slower capacity fade rate per cycle
data.resistance_growth_rate = 0.0001; % Even slower resistance growth rate per cycle

% Ensure the battery is simulated to last years by modifying simulation step size and total simulation time
% Add thermal management or cycle limits to slow down stress on the battery
end
