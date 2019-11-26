
% Utility functions used later on to provide a cleaner interface to 
% our data, as well as some calculations like FFT etc.

1;

% Generates the specified test signal (Sawtooth wave) to check our FFT 
% Calculation
function output=s(times)
  Amp = 1000;
  Len = 0.01;
  
  output = (times>0) .* (-Amp/Len .* times + Amp);
  output = output + (-(Amp*Len).*(times-Len)./2 + Amp) .* (times > Len);
end

%%%%%%%
% Convenience functions, they do no calculations but provide 
% clean data access
%%%%%%%
function output=tstamps(data)
  output=data(:,1);
end
function output=vTransformer(data)
  output=data(:,2);
end
function output=vGate(data)
  output=data(:,3);
end
function output=current(data)
  output=data(:,4);
end


%%%%%%%%
% FFT-Related functions
%%%%%%%%

% Calculate the FFT for our signal "Data", assuming that we have
% "periods" periods. This is used to give us only the fourier coefficients for 
% our harmonics (50Hz, 100Hz, etc.), while leaving out lower frequencies
% "n" specifies how many coefficients we want.
function output=period_fft(data, n, periods)
  raw_fft = (fft(data) / size(data,1));
  
  output = [raw_fft(1); 2*raw_fft(1+periods:periods:1+n*periods)];
end

% Reconstruct our signal from FFT coefficients, useful for plotting.
% CAUTION: Assumes the coefficients are for frequencies k*50Hz!
% "timecodes" is a list of time indices for which we want to calculate the signal
function output=fft_reconstruct(coefficients, timecodes, base_frequency)
  if(nargin == 2)
    base_frequency = 50;
  end

  frequencies = base_frequency .* (0:(size(coefficients)-1));
  
  eulers = exp(-2*pi*i .* frequencies .* timecodes);
  eulers = coefficients' .* eulers;
  
  output=real(sum(eulers,2));
end

%%%%%%
% Data preparation functions
%%%%%

% Return the number of 50Hz periods that our data contains
% Assuming "Data" is the full set (Timecodes, voltages, etc.)
function output=nPeriods(data)
  timecodes = data(:,1);
  
  output = (max(timecodes) - min(timecodes)) * 50;
end

% Assuming we have a 50Hz signal, cut our data to a clean multiple of
% the period (1s/50)
function output=cut_periods(data, n)
  dT = data(2,1) - data(1,1);
  
  if(nargin == 1)
    wanted_time = 1/50 * round(nPeriods(data));
  else
    wanted_time = n/50;
  end
  
  wanted_samples = wanted_time / dT;
  
  output=data(1:wanted_samples, :);
end