% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP - MAXYMUS Image Evaluation Program                %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function miep
    myMiep = miepgui;
    try
        if ~isdeployed
            waitfor(myMiep)
        else
            myMiep;
        end
    catch errMiep
        disp(errMiep)
        delete(myMiep)
    end
end