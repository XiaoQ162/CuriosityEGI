% Reference:
% https://sccn.ucsd.edu/wiki/Makoto%27s_preprocessing_pipeline
% https://sccn.ucsd.edu/wiki/Makoto%27s_useful_EEGLAB_code

clear all; clc;
eeglab;

% set path
root_path = 'C:\\Users\\xjl19\\Desktop\\CuriosityEGI';
mff_path = fullfile(root_path, 'FilteredTask');
set_path = fullfile(root_path, 'Task_set_uncleaned');
location_path = 'C:\\Users\\xjl19\\Desktop\\Matlab\\eeglab2021.1\\sample_locs\\GSN129.sfp';

for sub = [43]
    
    % set file name
    % fname = fullfile(mff_path, 'task_sample.mff');
    % outname = fullfile(set_path, 'task_sample.set');
    fname = fullfile(mff_path, strcat('tc_0', num2str(sub),'_fil.mff'));
    outname = fullfile(set_path, strcat('tc_0', num2str(sub),'_uncleaned.set'));
    sprintf('------------------- Processing %s -------------------', fname);

    % import data
    EEG = pop_mffimport({fname}, {'code'});

    % rename markers
    % rename code
    for i = 1:length(EEG.event)
        if convertCharsToStrings(EEG.event(i).code) == '0201' % 起点
            row0201 = i;
            while convertCharsToStrings(EEG.event(i).code) ~= '0500'
                i = i + 1;
            end
            if convertCharsToStrings(EEG.event(i - 1).code) == '0400'
                EEG.event(row0201).code = append('1' , num2str(str2num(EEG.event(i - 2).code)));
            end
        end
    end
    
    % rename type
    for i = 1:length(EEG.event)
        if convertCharsToStrings(EEG.event(i).type) == '0201' % 起点
            row0201 = i;
            while convertCharsToStrings(EEG.event(i).type) ~= '0500'
                i = i + 1;
            end
            if convertCharsToStrings(EEG.event(i - 1).type) == '0400'
                EEG.event(row0201).type = append('1' , num2str(str2num(EEG.event(i - 2).type)));
            end
        end
    end

    % remove useless channels
    EEG = pop_select(EEG, 'nochannel', {'E125', 'E128', 'E43', 'E48', 'E63', 'E73', 'E81', 'E88', 'E99', 'E120', 'E119', ...
                       'E1', 'E8', 'E14', 'E17', 'E21', 'E25', 'E32', 'E38', 'E121', 'E126', 'E127', ...
                       'E15', 'E22', 'E9', 'E18', 'E16', 'E10', 'E11', 'E6', 'E55', 'E62', 'E72', 'E75',...
                       'E68', 'E129', 'VREF', 'COM' });

    % resample
    EEG = pop_resample(EEG, 256);

    % filter
    EEG = pop_eegfiltnew(EEG, 'locutoff', 1);
    EEG = pop_eegfiltnew(EEG, 'hicutoff', 30);

    % save to .set
    EEG = pop_saveset(EEG, 'filename', outname, 'filepath', '');
    % EEG = pop_saveset(EEG);

end