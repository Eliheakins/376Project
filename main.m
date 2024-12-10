clear all; clc; close all; 
% independent variables (play around with these)
numSatelites = 4; 
numMoves = 50;
stepdist = 0.1; 
noisefactor = 1e-13; 
bearing=0;
lat = 90; % Initial latitude (degrees)
long = 0; % Initial longitude (degrees)

[error,initialPositions] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long);
figure();
plot(1:numMoves, error,'r')
title("num sat: 4")
hold on;
numSatelites = 5; 
[error,initialPositions] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long);
plot(1:numMoves, error,'b*')
legend("4 sats","5 sats")
