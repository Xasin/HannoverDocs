
clear all;

UTILS;

global IND_1 = cut_periods(dlmread("TEK00000.CSV", ",", 17, 0));
global IND_2 = cut_periods(dlmread("TEK00001.CSV", ",", 17, 0));
global IND_3 = cut_periods(dlmread("TEK00002.CSV", ",", 17, 0));

global Steuer = dlmread("Steuerkennlinie.csv");

%%% Coefficient calculation

global currentCoefficients;

currents = [current(IND_1), current(IND_2), current(IND_3)];
currentCoefficients = [];

for(i = (1:3))
  currentCoefficients(:,end+1) = period_fft(currents(:,i), 13, 8);
end

function plotCoeffs()
  global currentCoefficients;

  newplot();
  stem((0:13)*50, abs(currentCoefficients), "filled", "markersize", 8, "linewidth", 1);
  
  title("Stromoberschwingungskoeffizienten");
  legend("150°", "120°", "90°");
  
  xlabel("Frequenz in Hz");
  ylabel("Amplitude in A");
  
  print("Plot_5.4.png");
end

function powerCalc()
  global currentCoefficients;

  currentEffs = currentCoefficients / sqrt(2);
  
  currentOvertones = abs(currentEffs(3:end,:));
  currentOvertones = power(currentOvertones, 2);
  currentOvertones = sum(currentOvertones, 1);
  currentOvertones = sqrt(currentOvertones);
  
  currentBasetones = abs(currentEffs(2,:));
  
  THD = currentOvertones ./ currentBasetones .* 100
  
  newplot();
  bar(flip([150, 120, 90]), flip(THD));
  
  title("THD der Stromschwingungen");
  xlabel("Steuerwinkel in Grad");
  ylabel("THD in %");
  
  print("Plot_5.5.png");
  
  voltageBasetone = ones(1, 3) .* 24*exp(-i*pi/2);
  
  Verzerrungsblindleistungen = abs(voltageBasetone) .* currentOvertones
  
  complexPowers = voltageBasetone .* conj(currentEffs);
  Wirkleistungen = real(complexPowers(2, :))
  
  Grundschwingungsblindleistungen = imag(complexPowers(2, :))
  
  Scheinleistungen = sqrt(sum(power([Verzerrungsblindleistungen; Wirkleistungen; Grundschwingungsblindleistungen], 2)))
end

function calc_resistance()
  global IND_2;

  currentCut = current(IND_2)(1000:1500);
  voltageCut = vGate(IND_2)(1000:1500);
  
  regFunction = [ones(501, 1) currentCut];
  
  [m, b] = ols(voltageCut, regFunction)
  
  plot((0:500), voltageCut, (0:500), m(1) + m(2) * currentCut)
end

function plotSteuer()
  global Steuer;
  
  winkel = Steuer(:,1);
  
  steuerVals = Steuer(:,2:4);
  steuerVals = steuerVals ./ max(steuerVals)
  
  plot(winkel, steuerVals)
  grid minor
end

powerCalc();
