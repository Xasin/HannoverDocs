
clear all;

global Amp=1000;
global Len=0.01;
global freq=100000.0;

function output=s(times)
  global Amp;
  global Len;
  
  output = (times>0) .* (-Amp/Len .* times + Amp);
  output = output + (-(Amp*Len).*(times-Len)./2 + Amp) .* (times > Len);
end

function output=ffacts(times, freq)
  output = e .^ (-i.*2.*pi .* times .* freq');
end

function output=fC(times, signal, freq)
  complexFacts = ffacts(times, freq) .* signal;
  
  output = sum(complexFacts') ./ (size(times,2));
end

t=(0:1/freq:2*Len);
signal=s(t);


freqs=(1/Len) .* (0:10);

fourFacts = [1 , 2*ones(1, size(freqs,2)-1)] .* fC(t, signal, freqs)

waves = conj(ffacts(t, freqs)) .* fourFacts';

plot(t, waves, t, real(sum(waves)));