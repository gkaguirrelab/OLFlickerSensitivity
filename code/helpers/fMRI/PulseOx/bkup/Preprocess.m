function Preprocess(subjDir,dicomDir,pulsFile)

%  Preprocess dicoms
%
%   Usage: Preprocess(subjDir,dicomDir,pulsFile)
%
%   Sorts dicoms into series directories, converts to nifti files based on
%   series type (e.g. MPRAGE, BOLD, DTI), computes physiological regressors
%   from pulse oximeter data ('*.puls file) using PulseResp.m, ACPC aligns
%   anatomical image using ACPC Alignment module from Van Essen lab,
%   displays commands to run through Freesurfer pipeline in terminal.
%
%
%   Written by Andrew S Bock Feb 2014

if ~exist('pulsFile','var')
    fprintf('\nNo pulse file given\n');
end
% make a backup of dicom directory
%disp('Making backup of dicomDir')
copyfile(dicomDir,fullfile([dicomDir '_BAK']));
% sort dicoms within this directory
dicom_sort(dicomDir);
series = listdir(dicomDir,'dirs');
% process series types
if ~isempty(series)
        mpragect = 0;
        mp2ragect = 0;
        PDct = 0;
        boldct = 0;
        B0ct = 0;
        DTIct = 0;
    for s = 1:length(series)
        fprintf(['\nProcessing ' series{s} ' series ' num2str(s) ' of ' ...
            num2str(length(series)) '\n\n'])
        % Anatomical image
        if ~isempty(strfind(series{s},'MPRAGE'));
            mpragect = mpragect + 1;
            fprintf(['\nPROCESSING ANATOMICAL IMAGE ' num2str(mpragect) '\n']);
            % Convert dicoms to nifti
            outputDir = fullfile(subjDir,'MPRAGE',['00' num2str(mpragect)]);
            mkdir(outputDir);
            outFile = 'MPRAGE.nii.gz';
            dicom_nii(fullfile(dicomDir,series{s}),outputDir,outFile)
            system(['echo ' series{s} ' > ' fullfile(outputDir,'series_name')]);
            disp('done.')
        elseif ~isempty(strfind(series{s},'mp2rage'));
            mp2ragect = mp2ragect + 1;
            fprintf(['\nPROCESSING ANATOMICAL IMAGE ' num2str(mp2ragect) '\n']);
            % Convert dicoms to nifti           
            outputDir = fullfile(subjDir,'MP2RAGE',['00' num2str(mp2ragect)]);
            mkdir(outputDir);
            outFile = 'MP2RAGE.nii.gz';
            dicom_nii(fullfile(dicomDir,series{s}),outputDir,outFile)
            system(['echo ' series{s} ' > ' fullfile(outputDir,'series_name')]);
            disp('done.')            
        elseif ~isempty(strfind(series{s},'PD'));
            PDct = PDct + 1;
            fprintf(['\nPROCESSING PROTON DENSITY IMAGE ' num2str(PDct) '\n']);
            % Convert dicoms to nifti           
            outputDir = fullfile(subjDir,'PD',['00' num2str(PDct)]);
            mkdir(outputDir);
            outFile = 'PD.nii.gz';
            dicom_nii(fullfile(dicomDir,series{s}),outputDir,outFile)
            system(['echo ' series{s} ' > ' fullfile(outputDir,'series_name')]);
            disp('done.')             
        elseif ~isempty(strfind(series{s},'ep2d')) || ~isempty(strfind(series{s},'BOLD')) ...
                || ~isempty(strfind(series{s},'bold'));
            boldct = boldct + 1;
            fprintf(['\nPROCESSING BOLD IMAGE ' num2str(boldct) '\n']);
            % Convert dicoms to nifti           
            outputDir = fullfile(subjDir,'bold',['00' num2str(boldct)]);
            mkdir(outputDir);
            outFile = 'f.nii.gz';
            dicom_nii(fullfile(dicomDir,series{s}),outputDir,outFile)
            system(['echo ' series{s} ' > ' fullfile(outputDir,'series_name')]);
            echo_spacing(fullfile(dicomDir,series{s}),fullfile(subjDir,'bold',...
                ['00' num2str(boldct)]));
            disp('done.')                
        elseif ~isempty(strfind(series{s},'B0'));
            B0ct = B0ct + 1;
            if B0ct == 1;
                magDicomDir = fullfile(dicomDir,series{s});
                outputDir = fullfile(subjDir,'B0');
                mkdir(outputDir);
                dicom_nii(magDicomDir,outputDir,'mag_all.nii.gz');
                fprintf(['\nSeries ' series{s} ' contains B0 magnitude data\n\n']);
            elseif B0ct == 2;
                phaseDicomDir = fullfile(dicomDir,series{s});
                fprintf(['\nSeries ' series{s} ' contains B0 phase data\n\n']);
                outputDir = fullfile(subjDir,'B0');
                mkdir(outputDir);
                dicom_nii(phaseDicomDir,outputDir,'phase_all.nii.gz');
                B0calc(outputDir,magDicomDir,phaseDicomDir)
            end
        elseif ~isempty(strfind(series{s},'DTI'));
            DTIct = DTIct + 1;
            disp('done.')
        end
    end
end