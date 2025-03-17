clear all;
files = ["data_100", "data_80", "data_60", "data_40", "data_20", ...
         "data_-20", "data_-40", "data_-60", "data_-80", "data_-100"];
voltages = [-100, -80, -60, -40, -20, 20, 40, 60, 80, 100];

figure(1);
hold on;
xlabel('Time, s');
ylabel('Angle, rad');
title('Angle vs Time');

figure(2);
hold on;
xlabel('Time, s');
ylabel('Angular Speed, rad/s');
title('Angular Speed vs Time');

for i = 1:length(files)
    data = readmatrix(files(i));
    U = voltages(i);
    
    time = data(:, 1);
    time = time - time(1);
    angle = data(:, 2) * pi / 180;
    omega = data(:, 3) * pi / 180;
    
    figure(1);
    plot(time, angle, 'DisplayName', sprintf('Voltage %d V', U));
    
    figure(2);
    plot(time, omega, 'DisplayName', sprintf('Voltage %d V', U));
end

figure(1);
legend('show');
hold off;

figure(2);
legend('show');
hold off;

w_nls = [];
Tms = [];


for i = 1:length(files)
    data = readmatrix(files(i));
    U = voltages(i);
    U_pr = U;

    time = data(:, 1); 
    time = time - time(1);
    angle = data(:, 2) * pi / 180; % Второй столбец - угол, переводим в радианы
    omega = data(:, 3) * pi / 180; % Третий столбец - угловая скорость, переводим в рад/с

    time_apr = 0:0.01:1
    par0 = [0.1; 0.06]; % Начальные значения

    fun = @(par, time) U_pr * par(1) * (time - par(2) * (1 - exp(-time / par(2))));
    par = lsqcurvefit(@(par, time) fun(par, time), par0, time, angle);
    k = par(1);
    Tm = par(2);
    simOut = sim("result.slx", 'ReturnWorkspaceOutputs', 'on');
    time_theta = simOut.theta.Time; % Время для theta
    data_theta = simOut.theta.Data; % Значения theta
   
    w_nls = [w_nls, U_pr*k];
    Tms = [Tms, Tm];

    theta = U_pr * k * (time_apr - Tm * (1 - exp(-time_apr / Tm)));
    
    % График угла
    figure;
    hold on;
    plot(time, angle, 'b', 'DisplayName', 'Experimental Data');
    plot(time_apr, theta, '--r', 'LineWidth', 2, 'DisplayName', 'Approximation');
    xlabel('Time, s');
    ylabel('Angle, rad');
    title(sprintf('Angle vs Time (Voltage %d V)', U));
    legend('show');
    data_theta_interp = interp1(time_theta, data_theta, time, 'linear', 'extrap');
    plot(time, data_theta_interp, '-', 'DisplayName', sprintf('SIMULINK = %d V', U_pr));
    hold off;



    omega_apr = U_pr * k * (1 - exp(-time_apr / Tm));
    time_omega = simOut.omega.Time; % Время для omega
    data_omega = simOut.omega.Data; % Значения omega

    figure;
    hold on;
    plot(time, omega, 'b', 'DisplayName', 'Experimental ω');
    plot(time_apr, omega_apr, '--r', 'LineWidth', 2, 'DisplayName', 'Approximated ω');
    xlabel('Time, s');
    ylabel('Angular Speed, rad/s');
    title(sprintf('Angular Speed vs Time (Voltage %d V)', U));
    legend('show');
    data_omega_interp = interp1(time_omega, data_omega, time, 'linear', 'extrap');
    plot(time, data_omega_interp, '-', 'DisplayName', sprintf('SIMULINK = %d V', U_pr));
    hold off;
end

figure(1);
plot(voltages, flip(w_nls), '-', 'DisplayName', sprintf('SIMULINK = %d V', U_pr));
xlabel('voltages, V');
ylabel('Angular Speed, rad/s');

figure(2);
plot(voltages, flip(Tms), '-', 'DisplayName', sprintf('SIMULINK = %d V', U_pr));
xlabel('voltages, V');
ylabel('Tm, с');

