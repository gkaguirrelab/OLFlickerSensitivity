% Obtain the Dropbox path
[~, userID] = system('whoami');
userID = strtrim(userID);
switch userID
    case {'melanopsin' 'pupillab'}
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
    case 'connectome'
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/TOME_data/'];
    otherwise
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
end

% Set the Dropox path
setpref('OneLight', 'dropboxPath', dropboxBaseDir);

% Set the data path
setpref('OneLight', 'dataPath', dataPath);

% Set the modulation path
setpref('OneLight', 'modulationPath', fullfile(dropboxBaseDir, 'MELA_materials', 'modulations'));

% Set the materials path
setpref('OneLight', 'materialsPath', fullfile(dropboxBaseDir, 'MELA_materials'));

% Set the cache path
setpref('OneLight', 'cachePath', fullfile(dropboxBaseDir, 'MELA_materials', 'cache'));

% Set the default speak rate
setpref('OneLight', 'SpeakRateDefault', 230);
