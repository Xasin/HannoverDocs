

clear all;

function output=readData(fName) 
  output = dlmread(fName, ' ');
  
  output = output(:, 1:4);
end

global VA = readData("./Daten/V1_C.txt");
global VB = readData("./Daten/V2_C.txt");
global VC = readData("./Daten/V3_C.txt");

plot(VA);