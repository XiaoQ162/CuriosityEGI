clc;
eeglab;

% set path
root_path = 'C:\\Users\\123\\OneDrive\\Documents\\CuriosityEGI';
set_path = fullfile(root_path, '0301rename_xjl');
out_path = fullfile(root_path, '0301output');

% use EEGLAB GUI to load data set
% in EEGLAB GUI - Datasets - select multiple datasets - select all the
% dataset needed


% read csv file from local disk
% remember to include the full path of the file as the first paramater in
% function readtable()
Curiosity_T = readtable('C:\Users\123\OneDrive\Documents\CuriosityEGI\curi_continuous.csv');


% for sub = (start, end)
% inclusive for start and end
for sub = (7:8)
    % set file name
    % fname = 'tc_NUM_ICArm.set'
    % outname = 'tc_NUM_bins.set'
    % SETNUM < 10 : tc_00SETNUM
    % SETNUM > 10 : tc_0SETNUM
    if sub < 10
        fname = strcat('tc_00', num2str(sub),'_ICArm.set');
        outname = strcat('tc_00', num2str(sub),'_bins.set');
    else
        fname = strcat('tc_0', num2str(sub),'_ICArm.set');
        outname = strcat('tc_0', num2str(sub),'_bins.set');
    end  
    % import set
    EEG = pop_loadset(fname, set_path);
    

    % data slice
    % fetch all records where Participant.id == 7( you can this number to the
    % participant you want)
    % store the data slice in a temp table
    % referenct:
    % https://www.mathworks.com/matlabcentral/answers/366254-how-do-i-extract-certain-data-from-a-table
    Temp_T = Curiosity_T(Curiosity_T.ParticipantID == sub, :);
    
    % sort the table based on Trials Number
    Temp_T = sortrows(Temp_T,'Trials_thisN','ascend');
    
    % build a map object
    % map<key, val> : key -> val
    % key : Trials Num
    % val : Curiosity Response
    keySet = Temp_T.Trials_thisN;
    valSet = Temp_T.Curiosity_response;
    

    % you can use the following two commands to check the map's keySet and
    % valueSet
    % keys(M)
    % values(M)
    
    % you can access values by key
    % if the key is not in map, an error message would print in Command Window
    %
    % M(101) : 
    % here 101 is Trial Number, 
    % and the value it returned is the Curiosity Response of 101
    M = containers.Map(keySet, valSet);
    
    % rename markers
    % rename code
    for i = 1:length(EEG.event)
        if isKey(M, str2double(EEG.event(i).code)) % 起点
            rowTrial = i;
            row0301 = i;
            % next row which have val as '0301' 
            % is 2 lines below '000X'(trial num)
            while convertCharsToStrings(EEG.event(row0301).code) ~= '0301'
                row0301 = row0301 + 1;
            end
            
            str_response = num2str(M(str2double(EEG.event(rowTrial).code)));
            EEG.event(row0301).code = append(str_response , num2str(str2num(EEG.event(row0301).code)));
            EEG.event(row0301).type = append(str_response , num2str(str2num(EEG.event(row0301).code)));
        end
    end
    
    % save to .set
    EEG = pop_saveset(EEG, 'filename', outname, 'filepath', out_path);


end








