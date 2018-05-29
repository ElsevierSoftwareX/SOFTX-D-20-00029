% calculate CWT from BBX
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Nick Träger                                            %
% % traeger@is.mpg.de                                      %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evalCWT(obj)
%get timeSlices via data function, will run readBBX if required
timeSlices = obj.data('Movie');

%calculate CWT parameters
width = size(timeSlices,1);
height = size(timeSlices,2);
timeSteps = size(timeSlices,3);
bunchSpacing = 2*10^-9; %ns
samplingRate = 1/(bunchSpacing/obj.magicNumber);
counter = 1;
freqMin = 4.0e9;
freqMax = 4.5e9;
frequencyRange = [freqMin freqMax];

%calculates CWTs
for i=1:width
    for j=1:height           
        [wt, f] = cwt(reshape(timeSlices(i,j,:),1,[]), samplingRate);
        if ~exist('cwtSlices', 'var')
            cwtSlices = zeros(size(wt,1), size(wt,2));
        end        
        cwtSlices(:,:,counter) = wt;
        counter = counter + 1;
       
        if ~exist('icwtSlices', 'var')
            icwtSlices = zeros(width, height, timeSteps);
        end   
        icwtSlices(i,j,:) = icwt(wt,f,frequencyRange);

    end
end

%write results into evalStore
obj.evalStore.CWT.Frequency = f;
obj.evalStore.CWT.cwtStack = cwtSlices;
obj.evalStore.CWT.icwtStack = icwtSlices;