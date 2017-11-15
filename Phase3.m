function [banks,NMT_matrices,banksfail,n_banks,ibn_adjmat,opn_adjmat,...
    FailCount,FailedBankID,FailedBanks,ActiveBanks,num_ActiveBanks,num_FailedBanks,ActiveAssets,num_ActiveAssets,num_InactiveAssets] = ...
    Phase3(banks,NMT_matrices,banksfail,n_banks,m_assets,r_z,ibn_adjmat,opn_adjmat,AP,...
    FailCount,FailedBankID,FailedBanks,ActiveBanks,ActiveAssets,t,T)

tau = 4;

ea_holdings_mat = NMT_matrices(:,:,(4*t),1);
ea_port_mat     = NMT_matrices(:,:,(4*t),2);

for i = ActiveBanks
    
    banks(i).status(t) = '-';
    banks(i).failtime  = 0;
    
    % Assets after end-of-period returns paid on investment
    banks(i).balancesheet.assets.cash(t,tau) = banks(i).balancesheet.assets.cash(t,tau-1) +...
            (r_z).*banks(i).balancesheet.assets.investment(t);
        
    banks(i).balancesheet.assets.total(t,tau) = banks(i).balancesheet.assets.cash(t,tau)+...
        banks(i).balancesheet.assets.external_assets(t,tau);
    
    % Liabilities
    
    banks(i).balancesheet.liabilities.capital(t,tau) = banks(i).balancesheet.assets.total(t,tau)-...
        banks(i).balancesheet.liabilities.deposits(t,tau-2);
    
    banks(i).balancesheet.liabilities.total(t,tau) = banks(i).balancesheet.assets.total(t,tau);
    
    if t<5
        insolvencyrequirement(i) =  false;
    else
        insolvencyrequirement(i) = logical(banks(i).balancesheet.liabilities.capital(t,tau)   < 0 &&...
                                    banks(i).balancesheet.liabilities.capital(t-1,tau) < 0 &&...
                                    banks(i).balancesheet.liabilities.capital(t-2,tau) < 0 &&...
                                    banks(i).balancesheet.liabilities.capital(t-3,tau) < 0 && ...
                                    banks(i).balancesheet.liabilities.capital(t-4,tau) < 0);
    end
        
end

% 1. Identify banks with negative end-of-period capital (classified as insolvent)

for i = ActiveBanks
        
    if insolvencyrequirement(i)
        
        % Report bank as failed
        FailCount    = FailCount + 1;
        FailedBankID(i) = 1;
        
        banks(i).status(t)   = 'F';
        banks(i).IBrolewhenfail = banks(i).IBM.status(t);
        banks(i).failtime = t;
        
        fields = fieldnames(banks(i));
        
        for j = 1:length(fieldnames(banks))
            banksfail(i).(fields{j}) = banks(i).(fields{j});
        end
        
 % 2.  Divide external assets equally across failed bank' counterparties
        
        for j = banks(i).counterpartyids
            
            banks(j).balancesheet.assets.external_assets(t,tau) = ...
                banks(j).balancesheet.assets.external_assets(t,tau)+...
                (1/banks(i).num_counterparties(t)).*(banks(i).balancesheet.assets.external_assets(t,tau));
            
           banks(j).balancesheet.assets.external_asset_holdings((4*t),:) = ones(1,banks(j).balancesheet.assets.num_external_assets(t)).*...
               (banks(j).balancesheet.assets.external_assets(t,tau)./banks(j).balancesheet.assets.num_external_assets(t));
           
            banks(j).balancesheet.assets.external_asset_port((4*t),:) = banks(j).balancesheet.assets.external_asset_holdings((4*t),:).*...
                AP(banks(j).balancesheet.assets.external_asset_ids);
            
            ea_holdings_mat(i,banks(i).balancesheet.assets.external_asset_ids) = banks(i).balancesheet.assets.external_asset_holdings(4*t,:);
            ea_port_mat(i,banks(i).balancesheet.assets.external_asset_ids)     = banks(i).balancesheet.assets.external_asset_port(4*t,:);
             
        end
        
        banks(i).balancesheet.assets.external_assets(t,tau) = 0;
                
% 3. Adjust adjacency matrices for interbank and overlapping portfolios to remove all connections of the failed bank
        
        ibn_adjmat(i,:) = zeros(1,n_banks);
        ibn_adjmat(:,i) = zeros(1,n_banks)';
        
        opn_adjmat(i,:) = zeros(1,m_assets);
        
    else 
        banks(i).status(t)   = 'A';
        banks(i).IBrolewhenfail = [];
        banks(i).failtime    = T;
        
        continue       
    end  
    % Assets after end-of-period returns paid on investment
        banks(i).balancesheet.assets.total(t,tau) = banks(i).balancesheet.assets.cash(t,tau)+...
        banks(i).balancesheet.assets.external_assets(t,tau);
    
    % Liabilities
    banks(i).balancesheet.liabilities.capital(t,tau) = banks(i).balancesheet.assets.total(t,tau)-...
        banks(i).balancesheet.liabilities.deposits(t,tau-2);
    
    banks(i).balancesheet.liabilities.total(t,tau) = banks(i).balancesheet.assets.total(t,tau);
end

% Identify assets that are no longer active (no holdings by any active banks)
InactiveAssets = find(sum(opn_adjmat(:,ActiveAssets))==0);
ActiveAssets   = setdiff(ActiveAssets,InactiveAssets);

num_ActiveAssets   = numel(ActiveAssets);
num_InactiveAssets = numel(InactiveAssets);

% Update set of active and failed banks based on current iteration of phase 3
FailedBanks = unique([FailedBanks find(FailedBankID)]);
ActiveBanks = setdiff(ActiveBanks,FailedBanks);

num_ActiveBanks = numel(ActiveBanks);
num_FailedBanks = numel(FailedBanks);

NMT_matrices(:,:,(4*t),1) = ea_holdings_mat(:,:);
NMT_matrices(:,:,(4*t),2) = ea_port_mat(:,:);

end