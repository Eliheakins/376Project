clear all; clc; close all; 
% independent variables (play around with these)
numSatelites = 30; 
stepdist = 10; 
noisefactor = 1e-10; 
numPoints=100;

[error,actualPos, estPos, satPos] = GPSMove(numSatelites, numPoints, noisefactor);
plotGPS(estPos, actualPos, satPos)
figure();
plot(1:numPoints, error,'r')
title("num sat: 4")
hold on;
%numSatelites = 5; 
%[error,initialPositions, xAll, satPos] = GPSMove(numSatelites, earthCircum/stepdist, stepdist, noisefactor, bearing, lat, long);
%plotGPS(estPos, actualPos, satPos)
%plot(1:numMoves, error,'b*')
%legend("4 sats","5 sats")
