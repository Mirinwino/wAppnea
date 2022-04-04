function [means, stds, RMS_adj_NN, STD_adj_NN, NN50, pNN50] = get_time_domain_features(HRV)
% Time Domain Parameters
   
    % mean of NN intervals
        
        means = mean(HRV);
    
    % standard deviation of NN intervals
      
        stds = std(HRV);
        
    % Sfeatures on adjacent NN intervals
        
        NN50=0;

        for i = 1 : length(HRV)-1
            %NN differences
            diff(i) = HRV(i+1) - HRV(i);
            if ( diff(i) > 0.05)
                % # of NN adjacent intervals > 50 ms
                NN50 = NN50 + 1; 
            end
        end
        %pNN50 - percentage of NN intervals that differ by less than 50 ms from
        pNN50 = (NN50/length(HRV)) * 100;

        % STD of difference between adjacent NN intervals
        STD_adj_NN = std(diff);

        % RMS of difference between adjacent NN intervals
        
        RMS_adj_NN = rms(diff);

end