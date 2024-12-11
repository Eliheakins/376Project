clear all; clc; close all; 
% independent variables (play around with these)
maxIter=50;i=0;
errorTol=1e-4; %accurate within one meter
errorCount=zeros(1,71);
for numSatelites=30:100
    while i<maxIter 
        stepdist = 100; 
        noisefactor = 0; 
        bearing=90; %zero is north
        lat = 0; % Initial latitude (degrees)
        long = 0; % Initial longitude (degrees)
        
        earthCircum=40075;
        dist=40000;
        numMoves = dist/stepdist;
        [error,actualPos, estPos, satPos] = GPSMove(numSatelites, numMoves, stepdist, noisefactor, bearing, lat, long);
        if norm(error)>errorTol
            errorCount(numSatelites-29)=errorCount(numSatelites-29)+1;
        end
        i=i+1;
    end
end
disp(errorCount)
%plotGPS(estPos, actualPos, satPos)
%figure();
%plot(1:numMoves, error,'r')
%title("num sat: 4")
%hold on;

