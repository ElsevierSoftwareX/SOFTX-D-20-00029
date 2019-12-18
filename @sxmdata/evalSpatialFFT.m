% calculate Spatial-FFT from BBX
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Nick Träger                                            %
% % traeger@is.mpg.de                                      %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evalSpatialFFT(obj)
%get FFT via eval function, will run FFT if requried
fftdata = obj.eval('FFT');
sizeY = size(fftdata.Phase,1);
sizeX = size(fftdata.Phase,2);
nImages = size(fftdata.Phase,3);

%get resolution
Xres = abs((obj.header.Regions.PAxis.Max - obj.header.Regions.PAxis.Min)...
           /obj.header.Regions.PAxis.Points);
Yres = abs((obj.header.Regions.QAxis.Max - obj.header.Regions.QAxis.Min)...
           /obj.header.Regions.QAxis.Points);       
       
%calculate k-Axis
xLength = Xres*sizeX;
kxAxis = (-sizeX/2:sizeX/2-1)/xLength;

yLength = Yres*sizeY;
kyAxis = (-sizeY/2:sizeY/2-1)/yLength;

%get Phase-Images for spatial FFT
Phase = obj.evalStore.FFT.Phase;

%calculate Spatial-FFT
kImages = zeros(sizeY, sizeX, nImages);
for i = 1:nImages 
   kImages(:,:,i) = fftshift(fft2(Phase(:,:,i)));    
end    

%write results into evalStore
obj.evalStore.SpatialFFT.kImages = kImages;
obj.evalStore.SpatialFFT.kxAxis = kxAxis;
obj.evalStore.SpatialFFT.kyAxis = kyAxis;




