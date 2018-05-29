% calculate frequency spectrum from bbx
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evalFrequencySpectrum(obj)
%get FFT via eval function, will run FFT if requried
fftdata = obj.eval('FFT');

%calculate sum spectrum
obj.evalStore.FrequencySpectrum.Frequency = fftdata.Frequency;
obj.evalStore.FrequencySpectrum.Power = reshape(sum(sum(fftdata.Power,1),2),1,[])...
                                ./(size(fftdata.Power,1)*size(fftdata.Power,2));
