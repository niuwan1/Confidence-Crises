function[Results,assetprices,FailCount,cum_Fails,capitalshortfall,numnodes,numedges,density,avdegree,mu_A,mu_B] = ...
    simcollect(abmresults_allsims,abmresults_label,n_sims,sim_Results_agg,sim_Results_av,sim_Results_min,sim_Results_max,...
    assetprices,FailCount,numnodes,numedges,density,avdegree,mu_A,mu_B)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average results across simulations before passing onto visualisation functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Averaging across ABM runs to obtain balance sheet, interbank market and firesale results for visualitation
Results(1,:) = nanmean(sim_Results_av,3);
Results(2,:) = nanmean(sim_Results_min,3);
Results(3,:) = nanmean(sim_Results_max,3);
Results(4,:) = nanmean(sim_Results_agg,3);

assetprices = nanmean(assetprices,3);

% Average vector of bank failures across simulations
FailCount(1,:)  = mean(FailCount);
FailCount(2,:) = min(FailCount);
FailCount(3,:) = max(FailCount);

% Cumulative vector of failed banks after averaging across runs
cum_Fails(1,:) = cumsum(FailCount_av);
cum_Fails(2,:) = cumsum(FailCount_min);
cum_Fails(3,:) = cumsum(FailCount_max);

% Identity of failed banks varies across ABM runs: Compute total capital loss due to failures in each run
for k = 1:n_sims
    Failures_sims = abmresults_allsims.(abmresults_label{k}).FailedBanks; 
    NumFails  = numel(Failures_sims);
    
    capitalshortfall_vec = zeros(NumFails,T);

    for i=1:NumFails
        capitalshortfall_vec(i,Failures_sims(i).failtime) = ...
            abmresults_allsims.(abmresults_label{k}).vars.balancesheet{'Capital',end};
    end
    
    sim_capitalshortfall(k,:) = abs(sum(capitalshortfall_vec));        
end

capitalshortfall(1,:) = mean(sim_capitalshortfall);
capitalshortfall(2,:) = min(sim_capitalshortfall);
capitalshortfall(3,:) = max(sim_capitalshortfall);

% Network structure evolution across ABM runs
numnodes(1,:) = mean(numnodes);
numnodes(2,:) = min(numnodes);
numnodes(3,:) = max(numnodes);

numedges(1,:) = mean(numedges);
numedges(2,:) = min(numedges);
numedges(3,:) = max(numedges);

density(1,:)  = mean(density);
density(2,:)  = min(density);
density(3,:)  = max(density);

avdegree(1,:) = mean(avdegree);
avdegree(2,:) = min(avdegree);
avdegree(3,:) = max(avdegree);   

mu_A(1,:) = mean(mu_A);
mu_A(2,:) = min(mu_A);
mu_A(3,:) = max(mu_A);

mu_B(1,:) = mean(mu_B);
mu_B(2,:) = min(mu_B);
mu_B(3,:) = max(mu_B);

end