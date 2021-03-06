% calculate FFT from BBX
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% %	Joachim Gr?fe / Nick Tr?ger                            %
% % graefe@is.mpg.de / traeger@is.mpg.de                   %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evalFFT(obj)
%get timeSlices via data function, will run readBBX if required
timeSlices = obj.data('Movie');

%calculate FFT parameters
width = size(timeSlices,1);
height = size(timeSlices,2);
timeSteps = size(timeSlices,3);
bunchSpacing = 2*10^-9; %ns
samplingRate = 1/(bunchSpacing/obj.magicNumber);

% %init storage
% power = zeros(width,height,timeSteps);
% amplitude = zeros(width,height,timeSteps);
% phase = zeros(width,height,timeSteps);
% 
% %calculates FFTs by looping
% for i=1:width
%     for j=1:height
%         ijfft = fftshift(fft(timeSlices(i,j,:),timeSteps));
%         power(i,j,:) = ijfft.*conj(ijfft)/timeSteps;
%         amplitude(i,j,:) = abs(ijfft);
%         phase(i,j,:) = angle(ijfft);
%     end
% end

%calculates FFTs
ffts = fftshift(fft(timeSlices,[],3),3);
amplitude = abs(ffts);
phase = angle(ffts);
power = amplitude.^2/timeSteps;

%write results into evalStore
obj.evalStore.FFT.Frequency = (-floor(timeSteps/2):floor(timeSteps/2))*(samplingRate/timeSteps);
obj.evalStore.FFT.Power = power;
obj.evalStore.FFT.Amplitude = amplitude;
obj.evalStore.FFT.Phase = phase;