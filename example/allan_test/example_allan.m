clear;
clc;
close all;

%% : read matlabe internal dataset 
% load('LoggedSingleAxisGyroscope', 'omega', 'Fs')
% gyroReading = omega;

%% ADIS16488 dataset
% load('adis16488_gyr.mat');
% gyroReading = omega(:,1);
% gyroReading = deg2rad(gyroReading);

%%  ch00   deg/s    m/s^(2)

load('./allan_plot_ch100/ch100.mat');
gyroReading = gyroReading(:,2);
gyroReading = deg2rad(gyroReading);
accelReading = accelReading(:,2);
accelReading = accelReading *  9.8066;
Fs = 400;


%% 
% data = ch_data_import('UranusData.csv');


%% https://github.com/Aceinna/gnss-ins-sim
% VRW 单位:                    m/s/sqrt(hr)           'accel_vrw': np.array([0.3119, 0.6009, 0.9779]) * 1.0,
% 加速度零偏不稳定性:     m/s^(2)                 'accel_b_stability': np.array([1e-3, 3e-3, 5e-3]) * 1.0,
% ARW 单位:                    deg/sqrt(hr)           'gyro_arw': np.array([0.25, 0.25, 0.25]) * 1.0,
% 角速度零偏稳定性:        deg/h                     'gyro_b_stability': np.array([3.5, 3.5, 3.5]) * 1.0,  

% M = csvread('gyro-0.csv',1 ,0);
% gyroReading = M(:,1);
% gyroReading = deg2rad(gyroReading); 
% 
% M = csvread('accel-0.csv',1 ,0);
% Fs = 100;
% accelReading = M(:,1);


%% 陀螺仿真 , 仿真输出单位为 rad/s
% B = 0.00203140909966965;
% N = 0.0125631765533906;
% K = 9.38284069320333e-05;
% L =2160000;
% Fs = 100;
% 
% 
% gyro = gyroparams('NoiseDensity', N, 'RandomWalk', K,'BiasInstability', B);
% acc = zeros(L, 3);
% angvel = zeros(L, 3);
% imu = imuSensor('SampleRate', Fs, 'Gyroscope', gyro);
% [~, omega ] = imu(acc, angvel);
% omega  = omega (:,1);
 

 %% 加计仿真, 仿真输出单位为 m/s^(2)
% B = 0.00203140909966965;
% N = 0.0125631765533906;
% K = 9.38284069320333e-05;
% L =2160000;
% Fs = 100;
% 
% 
% SpecAcc = accelparams('NoiseDensity', N, 'RandomWalk', K,'BiasInstability', B);
% acc = zeros(L, 3);
% angvel = zeros(L, 3);
% imu = imuSensor('SampleRate', Fs, 'Accelerometer', SpecAcc);
% [accelReading, ~] = imu(acc, angvel);
% accelReading = accelReading(:,1);


            
%% 运行陀螺 allan
[avar1, tau1 , N, K, B] = ch_allan(gyroReading , Fs, true);
fprintf('GYR: 零偏不稳定性                                                             %frad/s                    或   %fdeg/h \n', B, rad2deg(B)*3600);
fprintf('GYR: 噪声密度(角度随机游走, ARW, Noise density)              %f(rad/s)/sqrt(Hz)     或  %f deg/sqrt(h)\n', N, rad2deg(N)*3600^(0.5));
fprintf('GYR: 角速率随机游走, bias variations ("random walks")       %f(rad/s)sqrt(Hz)       或  %f deg/h/sqrt(h)\n', K, rad2deg(K) * (3600^(1.5)));



%% 运行加速度计 allan
[avar1, tau1 , N, K, B] = ch_allan(accelReading, Fs, true);

fprintf('ACC: 零偏不稳定性                                                                                       %fm/s^(2)                       或   %fmg  或  %fug\n', B, B / 9.80665 *1000,  B / 9.80665 *1000*1000);
fprintf('ACC: 噪声密度(速率随机游走,VRW, Noise Density, Rate Noise Density)          %f(m/s^(2))/sqrt(Hz)        或   %f m/s/sqrt(hr)\n', N, N * 3600^(0.5));
fprintf('ACC: 加速度随机游走，bias variations ("random walks")                               %f(m/s^(2)sqrt(Hz))\n',  K);



