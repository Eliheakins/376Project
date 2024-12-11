clear all; clc; close all; 
% independent variables (play around with these)
numSatelites = 200; 
stepdist = 100; 
noisefactor = 0; 
bearing=90; %zero is north
lat = 0; % Initial latitude (degrees)
long = 0; % Initial longitude (degrees)

earthCircum=40075;
dist=40000;
numMoves = dist/stepdist;
[error,actualPos, estPos, satPos] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long);
plotGPS(estPos, actualPos, satPos)
figure();
plot(1:numMoves, error,'r')
title("num sat: 4")
hold on;
%numSatelites = 5; 
%[error,initialPositions, xAll, satPos] = GPSMove(numSatelites, earthCircum/stepdist, stepdist, noisefactor, bearing, lat, long);
%plotGPS(estPos, actualPos, satPos)
%plot(1:numMoves, error,'b*')
%legend("4 sats","5 sats")
