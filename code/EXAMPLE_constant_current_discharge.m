
%% Example: constant-current discharge simulation
% In this example script, we will simulate the constant-current discharge
% of a lithium-ion battery using _Spectral li-ion SPM_.
% The parameters provided are for a LCO cell and were found in the 
% literature. Please see our paper for more details:
% 
% * Bizeray A.M. , Zhao, S., Duncan, S. R., and Howey, D. A., "Lithium-ion 
% battery thermal-electrochemical model-based state estimation using 
% orthogonal collocation and a modified extended Kalman filter", Journal 
% of Power Sources, vol. 296, pp. 400-412, 2015.
% <http://www.sciencedirect.com/science/article/pii/S0378775315300677 
% Publisher copy> and <http://arxiv.org/abs/1506.08689 Open access 
% pre-print>

%% 
% We first need to add the source files to the MATLAB path. Also, make sure
% the _chebdif.m_ file from the _MATLAB Differentiation Matrix Suite_ is 
% available on the MATLAB path.
% The _MATLAB Differentiation Matrix Suite_ can be downloaded at
% <http://uk.mathworks.com/matlabcentral/fileexchange/29-dmsuite>.
% We suggest to drop the unzip _dmsuite_ folder into the <../source source> 
% folder of _Spectral li-ion SPM_ and then run the following commands at 
% the beginning of your script.

% Adding required folder / subfolder on the MATLAB path
clear; close all;
addpath(genpath('source'));
addpath(genpath('model_parameters'));

%{
    Note: Make sure the 'MATLAB Differentiation Matrix Suite' developed by
    Weideman and Reddy is on your MATLAB path.
    Ref: JAC Weideman, SC Reddy, A MATLAB differentiation matrix suite, 
    ACM Transactions of Mathematical Software, Vol 26, pp 465-519 (2000).) 
    
    The 'MATLAB Differentiation Matrix Suite' is available for download at:
    http://uk.mathworks.com/matlabcentral/fileexchange/29-dmsuite
%}

%%
% All the model parameters are defined in the
% <../model_parameters/get_modelData.m get_modelData.m> file.
% The open-circuit potential and entropic coefficient for both electrodes
% are defined in the
% <../model_parameters/get_openCircuitPotential.m get_openCircuitPotential.m>
% file.  You should modify these files to define your own model parameters.
% A _data_ structure containing the parameters is created by calling the 
% <../model_parameters/get_modelData.m get_modelData.m> function:

data = get_modelData;    % Load the model parameters for a cell
%{  
    Model parameters can be defined by the user by editing the file
    'model_parameters/get_modelData.m'
    The open-circuit potential and entropy coefficients of each electrode
    are defined in the file 'model_parameters/openCircuitPotential.m'
%}  

%%
% The model is built by calling the <../source/get_model.m get_model.m>
% function which creates a _matrices_spm_ structure containing the
% differentiation matrices and the matrices A, B, C, and D of the diffusion
% state-space model.
% The Chebyshev nodes are computed by the <../source/get_nodes.m
% get_nodes.m> function with $N+1$ the number of Chebyshev nodes.

% Building the model
N = 6;      % N+1 is the number of Chebyshev nodes used to discretize 
            % the diffusion equation in each particle
nodes           = get_nodes(data,N);        % Create the Chebyshev nodes
matrices_spm    = get_model(data,nodes,N);  % Create the SPM model

%%
% The user must supply initial conditions to the model, i.e. the initial
% active material stoichiometry in anode _x1_init_ and cathode _y3_init_
% and the initial cell temperature _T_. The initial stoichiometry is 
% assumed uniform within each particle (cell at equilibrium).
% The initial state vector is then created in the _initSPM_ structure as 
% _initSPM.y0_ by calling the <../source/get_init.m get_init.m> function.

% Initial conditions
x1_init = data.x1_soc1;
y3_init = data.y3_soc1;
T_init  = data.T_amb;
%{
    The user must define 3 initial conditions:
        x1_init : initial stoichiometry in the anode particle (assumed uniform)
        y3_init : initial stoichiometry in the cathode particle (assumed uniform)
        T_init  : initial cell temperature
%}
initSPM = get_init(x1_init,y3_init,T_init,data,nodes,matrices_spm);


%%
% The input of the model is the current I in Amperes. Any current input can 
% be set by the user by defining an anonymous function _I_ of time, which
% returns a current vector associated with a time vector.

% Input current
C_rate = 0.01;     % C-rate
I = @(t) C_rate*data.C_nom*ones(size(t));   % Applied current [A]

%%
% The time span for the time integration can be set by defining the _tspan_
% vector.
% If the _tspan_ vector contains the initial and final times only, the time
% steps chosen by the solver will be returned.
% If the _tspan_ vector contains more than two values, the user-defined time 
% steps will be returned by the solver 
% (see <matlab:doc('ode45') ode45> help).
% The voltage limits to stop the simulation are defined in a _V_limit_ 
% vector containing the lower and upper cut-off voltages. 
% This vector is then provided to the
% <../source/cutOffVoltage.m cutOffVoltage.m> function.

% Time integration & Terminal conditions
% There are 2 terminal conditions: 
%   the simulation time span (i.e. model 1 hour)
%   the voltage limits (i.e. the minimum and maximum voltage is reached)
% Whichever occurs first will stop time integration
tspan = 0:10:3600*24;  	% Simulation time span
V_limit = [2 5];  	% Minimum and maximum voltage
% tspan = 0:10:3600;  	% Simulation time span
% V_limit = [3.0 4.2];  	% Minimum and maximum voltage
%%
% The model is then integrated in time by running the following code using
% the <matlab:doc('ode45') ode45> ODE solver. The function 
% <../source/cutOffVoltage.m cutOffVoltage.m> stops the simulation if the
% voltage reaches the limits defined in the _V_limit_ vector.
% The <../source/derivs_spm.m derivs_spm.m> function is the actual single
% particle model and returns the time derivative of the state vector 
% $\partial \mathbf{y} / \partial t$ at a given time $t$ and state 
% $\mathbf{y}$.

% Solution
event = @(t,y) cutOffVoltage(t,y,I,data,matrices_spm,V_limit);
fun = @(t,y) derivs_spm(t,y,I,data,matrices_spm);
opt = odeset('Events',event);
[result.time,result.state] = ode45(fun,tspan,initSPM.y0,opt);

%%
% The ODE solver <matlab:doc('ode45') ode45> only returns the time steps 
% and associated states of the model, other quantities of interest such as 
% voltage, temperature, SOC, concentration profiles etc. are computed by 
% the <../source/get_postproc.m get_postproc.m> function.
% The _result_ structure containing the _time_ and _state_ vectors computed
% by the ODE solver is provided to the 
% <../source/get_postproc.m get_postproc.m> function, which returns a 
% structure with additional quantities of interest.

% Postprocessing result (compute voltage, temperature, etc. from states)
result = get_postproc( result,data,nodes,matrices_spm,I);

%% Plotting some results
% We plot here some results for the 1C constant-current discharge 
% simulation, such as the voltage and temperature.
time_in_years = result.time / (365 * 24 * 3600);
% Voltage vs time
% figure;
% plot(time_in_years,result.voltage,'.-');
% xlabel('Time [Years]');
% ylabel('Voltage [V]');
% grid on;
figure;
plot(result.time,result.voltage,'.-');
xlabel('Time [s]');
ylabel('Voltage [V]');
grid on;
% Temperature vs time
figure;
plot(result.time,result.temperature,'.-');
xlabel('Time [s]');
ylabel('Temperature [K]');
grid on;


%%
% We can also plot the states of the model. For instance the evolution
% of the lithium concentration profile in each electrode particle is 
% plotted here as a surface plot.

% Concentration profiles vs time
[R1,T] = meshgrid(nodes.xc2xp(nodes.xr,'r1')*1e6,result.time);
[R3,~] = meshgrid(nodes.xc2xp(nodes.xr,'r3')*1e6,result.time);

figure;
subplot(121)
mesh(T,R1,result.cs1/data.cs1_max); grid on;
title('Anode')
xlabel('Time [s]');
ylabel('Radial coordinate r [microns]');
zlabel('Stoichiometry [-]');

subplot(122)
mesh(T,R3,result.cs3/data.cs3_max); grid on;
title('Cathode');
xlabel('Time [s]');
ylabel('Radial coordinate r [microns]');
zlabel('Stoichiometry [-]');

%%
% Save only time and voltage to a .mat file
time = result.time;          % Time in seconds
voltage = result.voltage;    % Voltage in volts
save('voltage_data.mat', 'time', 'voltage');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Or, if you prefer 2D graphs:

figure;
plot_idx = [1,101,201,301];     % Chosen times to plot

for i = 1:length(plot_idx)
    subplot(121)
    h1(i) = plot(nodes.xc2xp(nodes.xr,'r1')*1e6 , ...
        result.cs1(plot_idx(i),:)/data.cs1_max,'o-');
    xlabel('Radial coordinate r [microns]');
    ylabel('Stoichiometry [-]');
    title('Anode particle');
    hold on; grid on;
    
    subplot(122)
    h2(i) = plot(nodes.xc2xp(nodes.xr,'r3')*1e6 , ...
        result.cs3(plot_idx(i),:)/data.cs3_max,'o-');
    xlabel('Radial coordinate r [microns]');
    ylabel('Stoichiometry [-]');
    title('Anode particle');
    hold on; grid on;
end
legend_label = [ ...
    repmat('t = ',length(plot_idx),1),num2str(result.time(plot_idx)) , ...
    repmat(' s',length(plot_idx),1) ];

legend(h1,legend_label,'Location','Best');
legend(h2,legend_label,'Location','Best');
