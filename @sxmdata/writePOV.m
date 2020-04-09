function writePOV(obj, varargin)
%Function to export MIEP data to PovRay, requires working PovRay installation
    %check if BBX exists for this data
    if ~any(strcmp(obj.channels,'BBX'))
        errordlg('No movie to render', 'Error')
        return
    end
    
    %User input for output path if no path is given
    if isempty(varargin)
        %Get Frequency and directory from user input
        outpath = uigetdir([getenv('USERPROFILE') '\documents\'], 'Select Output Folder');
        if outpath == 0
            return
        end
        
        %Choose first frequency of FFT if no input by GUI
        guessFreqVal = round(length(obj.eval('FFT').Frequency)/2)+1;
        prompt = {'Select Frequency Slice to Render:'};
        dlgtitle = 'Frequency Slice';
        dims = [1 35];
        definput = {num2str(guessFreqVal)};
        freqValStr = inputdlg(prompt,dlgtitle,dims,definput);
        
        if isempty(freqValStr)
            return
        end
        freqVal = str2double(freqValStr{1});
        

        
    elseif length(varargin) == 2
        outpath = [varargin{2} '\POV-Ray'];
        freqVal = varargin{1};
    else
        errordlg('Please enter Frequency Slice and Output Path', 'Error')
        return
    end
    
    
    
    scanname = split(obj.header.Label, '.');
    filename = scanname{1};
    outfolder = [fullfile(outpath, filename) '\'];

    %Create the directory if it does not exist
    if ~exist(outfolder, 'dir')
       mkdir(outfolder)
    end

    %Look for POV-Ray engine
    povengine = 'C:\Program Files\POV-Ray\v3.7\bin\pvengine64.exe';
    if ~exist(povengine,'file')
        [exefile, exepath] = uigetfile('C:\Program Files\*.exe', 'Select POV-Ray .exe');
        povengine = [exepath exefile];
    end

    amplitude = obj.eval('FFT').Amplitude(:,:,freqVal);
    phase = obj.eval('FFT').Phase(:,:,freqVal);
    freq = obj.eval('FFT').Frequency(freqVal);

    %User Input for Render Settings
    prompt = {'Applied Field [mT]:','Number of Rendering Frames:',...
        'Gaussian Filter Width:', 'Aliasing Threshhold', 'Aliasing Depth'};
    definput = {'0', '50', '1.5', '0.2', '5'};
    userInput = inputdlg(prompt,'Enter Personal Information' ,[1 50] ,definput);
    
    if isempty(userInput)
        return
    end
    
    %gather output from user input
    field = [num2str(round(str2double(userInput{1}),3,'significant')) ' mT'];

    nFrames = str2double(userInput{2});
    filterWidth = str2double(userInput{3});
    aliasingThreshhold = str2double(userInput{4});
    aliasingDepth = str2double(userInput{5});
    
    if filterWidth == 0
        filterWidth = 0.000000000000001;
    end
    
    frequency = [num2str(round(freq/1e9,3,'significant')) ' GHz'];
    
    
    
    %read out resolutions from header
    [xRes, yRes] = getRes(obj);
    
    %check for long side and switch if neccessary
    if yRes*size(amplitude,1) < xRes*size(amplitude,2)
        amplitude = permute(amplitude,[2,1,3]);
        phase = permute(phase,[2,1,3]);
        tempXRes = xRes;
        xRes = yRes;
        yRes = tempXRes;

        switched = 1;
    else
        switched = 0;
    end
    
    %write dynamic image to png file
    writeDynImg(outfolder, filename, amplitude, phase, switched)
    
    %calculating and normalizing M
    M = NaN([nFrames, size(amplitude)]);
    for j = 1:nFrames
        M(j,:,:) = imgaussfilt(amplitude.* sin(2*pi*j/nFrames+phase), filterWidth);
    end
    M = M/max(abs(M(:)));

    %create X and Y
    [X,Y] = meshgrid(((0:size(M,3)-1)-(size(M,3)-1)/2)*xRes,((0:size(M,2)-1)-(size(M,2)-1)/2)*yRes);

    %PovRay matrix formation of Variables
    %creating cell array for M and rewrite it to pov-ray matrix with , and
    %brackets
    
    cellM = formPov(M, 'M');
    cellX = formPov(X, 'X');
    cellY = formPov(Y, 'Y');

    %write to povray file
    writePov(M, X, Y, cellM, cellX, cellY, xRes, yRes, frequency, field, outfolder, filename)
    
    %POV-Ray animation-file
    writePovIni(outfolder, filename, nFrames, aliasingThreshhold, aliasingDepth)
    
    %execute pov-ray
    execString = ['"', povengine, '" ', [outfolder filename '.ini'], ' +UA /EXIT'];
    system(execString);
    
    %import animation and write video
    writePovVideo(outfolder, filename, nFrames)


end


function writeDynImg(outfolder, infile, amplitude, phase, switched)
    
    hue = (phase+pi)/(2*pi);
    sat = ones(size(hue,1),size(hue,2));
    val = amplitude/max(amplitude(:));
    hsv(:,:,1) = hue;
    hsv(:,:,2) = sat;
    hsv(:,:,3) = val;
    
    dynPath = [outfolder infile '_dyn.png'];
    
    if ~switched
        hsvPic = flip(hsv2rgb(hsv),1);
    else
        hsvPic = hsv2rgb(hsv);
    end
    
    imwrite(hsvPic, dynPath);

end
function [xRes, yRes] = getRes(obj)
    % get x and y resolution from header
    
    x = obj.header.Regions.PAxis;
    xRes = (x.Max - x.Min) / x.Points;
    
    y = obj.header.Regions.QAxis;
    yRes = (y.Max - y.Min) / y.Points;
end
function cellMat = formPov(mat, matName)

    cellMat = cellstr(string(mat));
    h = waitbar(0, ['Generate POV-Ray format of ' matName '...']);
    
    if length(size(cellMat)) == 3
        %dimension of M is 3
        for j = 1:size(cellMat,1)
            waitbar(j/size(cellMat,1), h)
            for k = 1:size(cellMat,2)
                for l = 1:size(cellMat,3)


                    if j == 1 && k == 1 && l == 1
                        cellMat{j,k,l} = strcat('{{{', cellMat{j,k,l});
                    elseif k == 1 && l == 1
                        cellMat{j,k,l} = strcat('{{', cellMat{j,k,l});
                    elseif l == 1
                        cellMat{j,k,l} = strcat('{', cellMat{j,k,l});
                    end

                    if j == size(cellMat,1) && k == size(cellMat,2) && l == size(cellMat,3)
                        cellMat{j,k,l} = strcat(cellMat{j,k,l},'}}}');
                    elseif k == size(cellMat,2) && l == size(cellMat,3)
                        cellMat{j,k,l} = strcat(cellMat{j,k,l},'}}');
                    elseif l == size(cellMat,3)
                        cellMat{j,k,l} = strcat(cellMat{j,k,l},'}');
                    end

                end
            end
        end
        cellMat = strcat(cellMat, ',');
        cellMat{end,end,end} = cellMat{end,end,end}(1:end-1);
        
    elseif length(size(cellMat)) == 2
        %dimension of X,Y is 2
        for j = 1:size(cellMat,1)
            waitbar(j/size(cellMat,1), h)
            for k = 1:size(cellMat,1)

                if j == 1 && k == 1
                    cellMat{j,k} = strcat('{{', cellMat{j,k});

                elseif k == 1
                    cellMat{j,k} = strcat('{', cellMat{j,k});
                end

                if j == size(cellMat,1) && k == size(cellMat,2)
                    cellMat{j,k} = strcat(cellMat{j,k},'}}');
                elseif k == size(cellMat,2)
                    cellMat{j,k} = strcat(cellMat{j,k},'}');
                end

            end
        end

        cellMat = strcat(cellMat, ',');
        cellMat{end,end} = cellMat{end,end}(1:end-1);
    end
    
    delete(h)
end
function writePov(M, X, Y, cellM, cellX, cellY, xRes, yRes, frequency, field, outfolder, infile)
    filePathPov = [outfolder infile '.pov'];
    dynPath = [outfolder infile '_dyn.png'];
    
    %open file
    fid = fopen(filePathPov,'wt');
    fprintf(fid, 'global_settings { charset utf8 }\n');
    %write M-matrix
    fprintf(fid, '#declare M = array[%d][%d][%d]\n\n', size(M,1), size(M,2), size(M,3));

    for j = 1:size(M,1)
        for k = 1:size(M,2)
            s = strcat(char(cellM{j,k,1}),char(cellM{j,k,2}));
            for l = 3:size(M,3)
                s = strcat(s,char(cellM{j,k,l}));
            end
            fprintf(fid, '%s\n', s);
        end
    end

    fprintf(fid, '#local sizeM1 = dimension_size(M,1);\n');
    fprintf(fid, '#local sizeM2 = dimension_size(M,2);\n');
    fprintf(fid, '#local sizeM3 = dimension_size(M,3);\n\n');

    %write fPhase-matrix
    fprintf(fid, '#declare X = array[%d][%d]\n\n', size(X,1), size(X,2));
    fprintf(fid, '\n');
    for j = 1:size(X,1)
        s = strcat(char(cellX{j,1}),char(cellX{j,2}));
        for k = 3:size(X,2)
            s = strcat(s,char(cellX{j,k}));
        end
        fprintf(fid, '%s\n', s);
    end


    fprintf(fid, '\n\n');
    fprintf(fid, '#local minX = %d;\n', min(min(X)));
    fprintf(fid, '#local maxX = %d;\n', max(max(X)));


    fprintf(fid, '#declare Y = array[%d][%d]\n\n', size(Y,1), size(Y,2));
    fprintf(fid, '\n');
    %write fAmp-matrix

    for j = 1:size(Y,1)
        s = strcat(char(cellY{j,1}),char(cellY{j,2}));
        for k = 3:size(Y,2)
            s = strcat(s,char(cellY{j,k}));
        end
        fprintf(fid, '%s\n', s);
    end

    fprintf(fid, '\n\n');
    fprintf(fid, '#local minY = %d;\n', min(min(Y)));
    fprintf(fid, '#local maxY = %d;\n', max(max(Y)));

    fprintf(fid, '#include "math.inc"\n');

    %write POV-Ray light source setup
    r = 1.5*yRes*size(M,2);
    theta = 60;
    phi = 80;
    fprintf(fid, 'background { color rgb <1,1,1> }');
    fprintf(fid, '#declare r = %d;\n', r);
    fprintf(fid, '#declare theta = %d;\n', theta);
    fprintf(fid, '#declare phi = %d;\n', phi);
    fprintf(fid, '#declare camLoc = <r*sind(theta)*sind(phi),r*cosd(theta),r*sind(theta)*cosd(phi)>;\n');
    fprintf(fid, 'camera {\n');
    fprintf(fid, 'location camLoc\n');
    
    camerashift = -yRes*size(M,2)/4;
    fprintf(fid, 'look_at <0,%d,0>}\n', camerashift);


    fprintf(fid, 'light_source{%d*0.4*<2,1.5,1>\n', size(M,2)*yRes);
    fprintf(fid, 'color rgb 1.5 }\n');

    %write POV-Ray setup sequence
    %3D(t)
    fprintf(fid, '#declare GridSize = sizeM2*sizeM3;\n');
    fprintf(fid, '#declare PointCount = sizeM2*sizeM3;\n');
    fprintf(fid, '#declare NumberOfFaces = 2*(sizeM2-1)*(sizeM3-1);\n'); 
    fprintf(fid, '#declare tempM = array[sizeM2*sizeM3]\n');
    fprintf(fid, '#for (i,0,sizeM2-1)\n');
    fprintf(fid, '#for (j,0,sizeM3-1)\n');
    fprintf(fid, '#declare tempM[i*sizeM3+j] = M[clock][i][j];\n'); 
    fprintf(fid, '#end\n');
    fprintf(fid, '#end\n');
    fprintf(fid, 'mesh2 {\n');
    fprintf(fid, 'vertex_vectors {\n');
    fprintf(fid, 'PointCount,\n');
    fprintf(fid, '#for (i,0,sizeM2-1)\n');
    fprintf(fid, '#for (j,0,sizeM3-1)\n');
    fprintf(fid, '<X[i][j],%d*tempM[i*sizeM3+j],Y[i][j]>,\n', size(M,2)*yRes/40);
    fprintf(fid, '#end\n');
    fprintf(fid, '#end\n');
    fprintf(fid, '}\n');
    fprintf(fid, 'texture_list {\n');
    fprintf(fid, 'NumberOfFaces\n');
    fprintf(fid, '#declare n = 0;\n');
    fprintf(fid, '#for (i,0,sizeM2-2)\n');
    fprintf(fid, '#for (j,0,sizeM3-2)\n');
    fprintf(fid, '#local K = i*(sizeM3)+j;\n');
    fprintf(fid, '#declare tempColor1 = 3*(tempM[K]+tempM[K+1]+tempM[K+sizeM3])/3;\n');
    fprintf(fid, '#declare tempColor2 = 3*(tempM[K+1]+tempM[K+sizeM3+1]+tempM[K+sizeM3])/3;\n');
    fprintf(fid, '#if (tempColor1 > 0)\n');
    fprintf(fid, 'texture{ pigment{\n');
    fprintf(fid, 'color rgb <1,1,1>-<0,tempColor1,tempColor1>}\n');
    fprintf(fid, 'finish { phong 1 }\n');
    fprintf(fid, 'scale 0.2\n');
    fprintf(fid, '}\n');
    fprintf(fid, '#else\n');
    fprintf(fid, 'texture{ pigment{\n');
    fprintf(fid, 'color rgb <1,1,1>+<tempColor1,tempColor1,0>}\n');
    fprintf(fid, 'finish { phong 0.1 }\n');
    fprintf(fid, 'scale 0.2\n');
    fprintf(fid, '}\n');
    fprintf(fid, '#end\n');
    fprintf(fid, '#if (tempColor2 > 0)\n');
    fprintf(fid, 'texture{ pigment{\n');
    fprintf(fid, 'color rgb <1,1,1>-<0,tempColor2,tempColor2>}\n');
    fprintf(fid, 'finish { phong 0.1 }\n');
    fprintf(fid, 'scale 0.2\n');
    fprintf(fid, '}\n');
    fprintf(fid, '#else\n');
    fprintf(fid, 'texture{ pigment{\n');
    fprintf(fid, 'color rgb <1,1,1>+<tempColor2,tempColor2,0>}\n');
    fprintf(fid, 'finish { phong 0.1 }\n');
    fprintf(fid, 'scale 0.2\n');
    fprintf(fid, '}\n');
    fprintf(fid, '#end\n'); 
    fprintf(fid, '#declare n = n + 2;\n');
    fprintf(fid, '#end\n');
    fprintf(fid, '#end\n');
    fprintf(fid, '}\n');
    fprintf(fid, 'face_indices{\n');
    fprintf(fid, 'NumberOfFaces\n');
    fprintf(fid, '#declare n = 0;\n');
    fprintf(fid, '#for (i,0,sizeM2-2)\n');
    fprintf(fid, '#for (j,0,sizeM3-2)\n');
    fprintf(fid, '#local K = i*(sizeM3)+j;\n');
    fprintf(fid, '<K,K+1,K+sizeM3>,n\n');
    fprintf(fid, '<K+1,K+sizeM3+1,K+sizeM3>, n+1\n');
    fprintf(fid, '#declare n = n + 2;\n');
    fprintf(fid, '#end\n');
    fprintf(fid, '#end\n');
    fprintf(fid, '}\n');
    fprintf(fid, '}\n\n\n');

    %Axis (box + cylinder + cone)
    tipscale = min([max(max(Y))-min(min(Y)) max(max(X))-min(min(X))])/8;
    arrowDiameter = yRes*size(M,2)/200;
    boxshift = camerashift;
    boxThickness = yRes*size(M,2)/100;
    fprintf(fid, '#include "shapes.inc"\n');
    fprintf(fid, '#declare boxshift = %d;\n', boxshift);
    fprintf(fid, '#declare boxThickness = %d;\n', boxThickness);
    fprintf(fid, 'object{\n');
    fprintf(fid, 'Round_Box(<-maxX,boxshift,-minY>, <maxX,boxshift+boxThickness,minY>, boxThickness/2, 0)\n');
    fprintf(fid, 'texture{ pigment { image_map{ png "%s"}\n', dynPath);
    fprintf(fid, 'scale <maxX-minX,-1*(maxY-minY),1> rotate <270,0,0> translate <(maxX-minX)/2,0,(maxY-minY)/2> }\n');
    fprintf(fid, 'finish { ambient 1 diffuse 0.9 phong 0.1}\n');
    fprintf(fid, '}\n');
    fprintf(fid, '}\n');
    
    %scale arrows
    %box
    fprintf(fid, 'union{');
    fprintf(fid, 'box{ <-1,-1,-1> <1,1,1> \n');
    fprintf(fid, 'scale <maxX-%d,%d,0.5*%d>} \n', tipscale, arrowDiameter, arrowDiameter);
    %tip 1
    fprintf(fid, 'prism{ -1, 1, 4 <0,-1>, <0,1>, <1,0>, <0,-1> \n');
    fprintf(fid, 'scale <%d,%d,2*%d> translate<maxX-%d,0,0>}\n', tipscale,arrowDiameter,arrowDiameter,tipscale);
    %tip 2
    fprintf(fid, 'prism{ -1, 1, 4 <0,-1>, <0,1>, <-1,0>, <0,-1> \n');
    fprintf(fid, 'scale <%d,%d,2*%d> translate<-maxX+%d,0,0>}\n', tipscale,arrowDiameter,arrowDiameter,tipscale);
    %move union
    fprintf(fid, 'rotate<0,0,0> translate<0,boxshift + boxThickness/2,maxY+5*%d>\n', arrowDiameter);
    fprintf(fid, 'texture{ pigment{ color rgb<0,0,0.7>} \n');
    fprintf(fid, 'finish { reflection 0 phong 1} }\n');
    fprintf(fid, '}\n\n');

    %box 2
    fprintf(fid, 'union{');
    fprintf(fid, 'box{ <-1,-1,-1> <1,1,1> \n');
    fprintf(fid, 'scale <0.5*%d,%d,maxY-%d>} \n', arrowDiameter, arrowDiameter, tipscale);
    %tip 1
    fprintf(fid, 'prism{ -1, 1, 4 <-1,0>, <1,0>, <0,1>, <-1,0> \n');
    fprintf(fid, 'scale <2*%d,%d,%d> translate<0,0,maxY-%d>}\n', arrowDiameter,arrowDiameter, tipscale,tipscale);
    %tip 2
    fprintf(fid, 'prism{ -1, 1, 4 <-1,0>, <1,0>, <0,-1>, <-1,0> \n');
    fprintf(fid, 'scale <2*%d,%d,%d> translate<0,0,-maxY+%d>}\n', arrowDiameter,arrowDiameter, tipscale,tipscale);
    %move union
    fprintf(fid, 'rotate<0,0,0> translate<maxX+5*%d,boxshift + boxThickness/2,0>\n', arrowDiameter);
    fprintf(fid, 'texture{ pigment{ color rgb<0,0,0.7>} \n');
    fprintf(fid, 'finish { reflection 0 phong 1} }\n');
    fprintf(fid, '}\n\n');
    

    %print text

    fprintf(fid, 'text{\n');
    fprintf(fid, 'ttf "arial.ttf" "%s µm" 1, 0\n', num2str(round(size(M,2)*yRes,3,'significant')));
    fprintf(fid, 'texture{ pigment{ color rgb<0,0,0.7>}\n');
    fprintf(fid, 'finish { reflection 0 phong 1} }\n');
    fprintf(fid, 'scale %d/20*<1,1,0.15> rotate<0,-90,90> translate<maxX+20*%d,boxshift + boxThickness/2,maxY/2>\n', size(M,2)*yRes, arrowDiameter);
    fprintf(fid, '}');
    fprintf(fid, 'text{');
    fprintf(fid, 'ttf "arial.ttf" "%s µm" 1, 0\n', num2str(round(size(M,3)*xRes,3,'significant')));
    fprintf(fid, 'texture{ pigment{ color rgb<0,0,0.7>}\n');
    fprintf(fid, 'finish { reflection 0 phong 1} }\n');
    fprintf(fid, 'scale %d/20*<1,1,0.15> rotate<0,-90,90> translate<3*maxX/4,boxshift + boxThickness/2,maxY+10*%d>\n', size(M,2)*yRes, arrowDiameter);
    fprintf(fid, '}');

    %print B & f
    fprintf(fid, 'text{\n');
    fprintf(fid, 'ttf "arial.ttf" "f = %s" 1, 0\n', frequency);
    fprintf(fid, 'texture{ pigment{ color rgb<0,0,0.7>}\n');
    fprintf(fid, 'finish { reflection 0 phong 1} }\n');
    fprintf(fid, 'scale %d/20*<1,1,0.15> rotate<0,-90,90> translate<maxX+20*%d,boxshift + boxThickness/2,-maxY/2>\n', size(M,2)*yRes, arrowDiameter);
    fprintf(fid, '}\n');
    fprintf(fid, 'text{\n');
    fprintf(fid, 'ttf "arial.ttf" "B = %s" 1, 0\n', field);
    fprintf(fid, 'texture{ pigment{ color rgb<0,0,0.7>}\n');
    fprintf(fid, 'finish { reflection 0 phong 1} }\n');
    fprintf(fid, 'scale %d/20*<1,1,0.15> rotate<0,-90,90> translate<maxX+35*%d,boxshift + boxThickness/2,-maxY/2>\n', size(M,2)*yRes, arrowDiameter);
    fprintf(fid, '}\n');

    %close file
    fclose(fid);
end
function writePovIni(outfolder, infile, nFrames, aliasingThreshhold, aliasingDepth)
    filePathPov = [outfolder infile '.pov'];
    filePathAni = [outfolder infile '.ini'];
    
    fid = fopen(filePathAni,'wt');

    fprintf(fid, '; POV-Ray animation ini file\n');
    fprintf(fid, 'Antialias=On\n');
    fprintf(fid, 'Sampling_Method=2\n');
    fprintf(fid, 'Antialias_Threshold=%d\n', aliasingThreshhold);
    fprintf(fid, 'Antialias_Depth=%d\n', aliasingDepth);
    fprintf(fid, 'Input_File_Name="%s"\n', filePathPov);
    fprintf(fid, 'Initial_Frame=1\n');
    fprintf(fid, 'Final_Frame=%d\n', nFrames);
    fprintf(fid, 'Initial_Clock=1\n');
    fprintf(fid, 'Final_Clock=%d\n', nFrames);
    fprintf(fid, 'Cyclic_Animation=on\n');
    fprintf(fid, 'Pause_when_Done=off\n');

    fclose(fid);

end
function writePovVideo(outfolder, infile, nFrames)
    videoPath = [outfolder infile '.avi'];
    
    vid = VideoWriter(videoPath);
    open(vid);

    nPictures = strcat('%0', num2str(floor(log10(nFrames))+1), 'd');

    for i = 1:10
        for curFrame = 1:nFrames
            curPic = [outfolder infile num2str(curFrame,nPictures) '.png'];
            writeVideo(vid, imread(curPic));
        end
    end
    close(vid);

end




