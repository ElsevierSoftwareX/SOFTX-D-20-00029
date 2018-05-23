% calculate FFT from BBX
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evalFFT(obj)
%get timeSlices via data function, will run readBBX if required
timeSlices = obj.data('Movie');

%calculate FFT parameters
width = size(timeSlices,1);
height = size(timeSlices,2);
timeSteps = size(timeSlices,3);
numFrequencies = nextpow2(timeSteps);
bunchSpacing = 2*10^-9; %ns
samplingRate = 1/(bunchSpacing/obj.magicNumber);

%init storage
power = zeros(width,height,numFrequencies);
amplitude = zeros(width,height,numFrequencies);
phase = zeros(width,height,numFrequencies);

%calculates FFTs
for i=1:width
    parfor j=1:height
        ijfft = fftshift(fft(timeSlices(i,j,:),numFrequencies));
        power(i,j,:) = ijfft.*conj(ijfft)/numFrequencies;
        amplitude(i,j,:) = abs(ijfft);
        phase(i,j,:) = angle(ijfft);
    end
end

%write results into evalStore
obj.evalStore.FFT.Frequency = (-numFrequencies/2:numFrequencies/2-1)*(samplingRate/numFrequencies);
obj.evalStore.FFT.Power = power;
obj.evalStore.FFT.Amplitude = amplitude;
obj.evalStore.FFT.Phase = phase;