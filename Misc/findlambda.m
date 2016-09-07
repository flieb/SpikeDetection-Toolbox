function lambda = findlambda(X,numspikes,fs)
%FINDLAMBDA get thresholding parameter for specified number of spikes
%
%   Input parameters:
%       X         : SocialSparsity neighborhood
%       numspikes : Number of spikes
%       fs        : Sampling frequency
%
%
%   Description:
%       findlamda(X,numspikes,fs) finds the lambda value for which we get 
%       the specified number of spikes by softthresholding. We start by
%       finding a lambda which is gives more than numspikes and a lambda
%       which gives less than numspikes and bisect the interval until we
%       get the correct number of spikes. 
%       Note: This is very slow...
%
%   Dependencies:
%       getSpikePositions

bl = max(X(:));
bu = max(X(:));
curr_numspikes = 0;
counter = 0;

while curr_numspikes < numspikes
    bl = bu;
    bu = bu / 2;
    
    curr_data = max(0,1-(bu./X));
    curr_data = sum(abs(curr_data),2);
    [~,curr_numspikes] = getSpikePositions(curr_data,fs);
    b = bu;
end


while (curr_numspikes ~= numspikes)
    
    b = (bl + bu)/2;
    
    curr_data = max(0,1-(b./X));
    curr_data = sum(abs(curr_data),2);
    
    [~,curr_numspikes] = getSpikePositions(curr_data,fs);
    
    if (curr_numspikes > numspikes)
        bu = b;
    else
        bl = b;
    end

end

lambda = b;
