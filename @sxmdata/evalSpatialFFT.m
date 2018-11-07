% calculate Spatial-FFT from BBX
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Nick Träger                                            %
% % traeger@is.mpg.de                                      %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evalSpatialFFT(obj)
%get FFT via eval function, will run FFT if requried
fftdata = obj.eval('FFT');
width = size(fftdata.Phase,1);
height = size(fftdata.Phase,2);
nImages = size(fftdata.Phase,3);

%get resolution
Xres = abs((obj.header.Regions.PAxis.Max - obj.header.Regions.PAxis.Min)...
           /obj.header.Regions.PAxis.Points);
Yres = abs((obj.header.Regions.QAxis.Max - obj.header.Regions.QAxis.Min)...
           /obj.header.Regions.QAxis.Points);       
       
%calculate k-Axis
kxRange = (-width/2):(width/2)-1;
kxAxis = kxRange./(Xres*width);

kyRange = (-height/2):(height/2)-1;
kyAxis = kyRange./(Yres*height);

%get Phase-Images for spatial FFT
Phase = obj.evalStore.FFT.Phase;

%calculate Spatial-FFT
kImages = zeros(width, height, nImages);
for i = 1:nImages 
   kImages(:,:,i) = fftshift(fft2(Phase(:,:,i)));    
end    

%write results into evalStore
obj.evalStore.SpatialFFT.kImages = kImages;
obj.evalStore.SpatialFFT.kxAxis = kxAxis;
obj.evalStore.SpatialFFT.kyAxis = kyAxis;




