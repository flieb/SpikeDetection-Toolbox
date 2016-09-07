function params = parseInput(in_struc, params)
%PARSEINPUT parses the input parameters from spikeDetection()
%
%   Description
%       parses the input from spikeDetection. Sets up the default
%       parameters and validates specified parameters. 
%
%   Author: F. Lieb, February 2016
%


if ~isfield(in_struc, 'SaRa')
    error('No Sampling Rate specified')
end

if ~isfield(in_struc, 'M')
    error('No Data specified');
end

fs = in_struc.SaRa;
[rows, cols] = size(in_struc.M);
L = rows;

if (rows < cols)
    warning('Are you sure, the data is stored columnwise? rows < cols!!!');
end






% DEFAULT PARAMETERS FOR DGTSF:
    % default time-sampling step for DGTSF: 1
    if ~isfield(params, 'a')
        params.a = 1;
    end

    % default number of frequency bins: 100
    if ~isfield(params, 'M')
        params.M = 100;
    end

    % default window: hann with small (in time-domain) window size
    if ~isfield(params, 'g')
        params.g = {'hann',2900/fs*L};
    end

    % default minimum frequency 
    if ~isfield(params, 'fmin')
        params.fmin = 400;
    else
        if mod(params.fmin,fs/L)
            warning('fmin value is not exactly compatible with specified fs=%d and signal length L=%d', fs, L);
        end
    end

    % default maximum frequency
    if ~isfield(params, 'fmax')
        params.fmax = 4000;
    else
        if mod(params.fmax,fs/L)
            warning('fmax value is not exactly compatible with specified fs=%d and signal length L=%d', fs, L);
        end
    end


% ADDITIONIAL DEFAULT PARAMETERS:
    % default method: auto
    if ~isfield(params, 'method')
        params.method = 'auto';
    end
    
    % default weight on pos and neg spikes:
    if ~isfield(params, 'spike_orientation')
        params.spike_orientation = 0;
    end
    
    % default weight method
    if ~isfield(params, 'groupWeight')
        params.groupWeight = '';
    end


% CHECK FOR ERRORS 
    if isfield(params,'method')
        switch params.method
            case 'auto'
                %everything allright
            case 'numspikes'
                if ~isfield(params,'numspikes')
                    error('please specify the number of spikes to detect');
                end
            case 'lambda'
                if ~isfield(params,'lambda')
                    error('please specify the lambda value');
                end
            otherwise
                error('wrong method, please see help for more information');
        end
    end
    
    if params.a ~= 1
        error('Different time-sampling step than 1 is not supported yet');
    end
    
    if params.M > 200
        warning('Choosing M larger than 200 increases computation time');
    end
    
    if params.fmin > params.fmax
        error('fmin cannot be larger than fmax');
    end
    
    if params.fmax > fs/2
        error('fmax cannot be larger than the nyquist frequency');
    end
    
    if  abs(params.spike_orientation) - 1 > 1
        error('spike orientation parameter can only be in the interval -1 (for mainly neg. spikes) and +1 (for mainly positive spikes)'); 
    end
    
    if (~strcmp(params.g{1},'hann') && exist('gabwin','file') ~= 2)
        error('only hanning window is supported, use "hann" as string identifier');
    end
    
    if params.g{2} ~= 2900*L/fs
        params.g{2} = 2900*L/fs;
    end
% SETTING ADDITIONAL PARAMETERS:
    params.fs = fs;
