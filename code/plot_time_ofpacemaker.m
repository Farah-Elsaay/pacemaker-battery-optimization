% Load voltage and time data
% Assuming the data is loaded into `time` and `voltage` arrays
% For example: [time, voltage] = load('voltage_data.mat');
% Replace with actual data loading step as needed.
load('voltage_data.mat'); % Replace with your file if applicable

% Parameters
V_cutoff = 2;  % Cutoff voltage in volts
I_pacemaker = 100e-6; % Pacemaker constant current draw [A]
battery_capacity = 0.5; % Battery capacity in Ampere-hours [Ah]

% Interpolate to find time to reach cutoff voltage
idx_cutoff = find(voltage <= V_cutoff, 1); % Find index where voltage hits cutoff
time_to_cutoff = time(idx_cutoff); % Time in seconds to cutoff

% Convert time to hours and years
time_to_cutoff_hours = time_to_cutoff / 3600; % Time in hours
time_to_cutoff_years = time_to_cutoff / (365 * 24 * 3600); % Time in years

% Calculate total lifetime based on battery capacity
% Lifetime = Total capacity / (Constant current draw)
total_lifetime_hours = battery_capacity / I_pacemaker; % Total hours
total_lifetime_years = total_lifetime_hours / (365 * 24); % Total years

% Display results
fprintf('Time to cutoff (single cycle): %.2f hours (%.2f years)\n', ...
        time_to_cutoff_hours, time_to_cutoff_years);
fprintf('Estimated total battery lifetime: %.2f years\n', total_lifetime_years);

% Plot the voltage vs time curve with cutoff point
figure;
plot(time, voltage, 'b-', 'LineWidth', 1.5);
hold on;
plot(time(idx_cutoff), voltage(idx_cutoff), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5); % Cutoff point
xlabel('Time [s]');
ylabel('Voltage [V]');
title('Voltage vs Time (Pacemaker Battery)');
grid on;
legend('Voltage Curve', 'Cutoff Point');
