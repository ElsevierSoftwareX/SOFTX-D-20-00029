% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP - MAXYMUS Image Evaluation Program                %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gr�fe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function miep
    myMiep = miepgui;
    try
        waitfor(myMiep)
    catch errMiep
        disp(errMiep)
        delete(myMiep)
    end
end