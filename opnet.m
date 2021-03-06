function [opn_adjmat] = opnet(n_banks,Pars_opnet,T,fig_output)

fig_output_Gephi = strcat(fig_output,'Network/Gephi/');

%---------------------------------------------------
%% Simulation of the overlapping portfolio network
%---------------------------------------------------

m_assets = Pars_opnet(1);
av_div   = Pars_opnet(2);

opn_adjmat    = zeros(n_banks,m_assets);
op_weightmat = zeros(n_banks,m_assets,T);
op_vizmat    = zeros(n_banks+m_assets,n_banks+m_assets);

av_asset_deg = (n_banks/m_assets)*av_div;
link_prob = av_div/m_assets;
  
n_runs = 0; 

while mean(sum(opn_adjmat(:,:),2)) ~= av_div && ...
        mean(sum(opn_adjmat(:,:))) ~= av_asset_deg && ...
         ismember(0,sum(opn_adjmat))
    
    n_runs = n_runs +1;
    for i = 1:n_banks
        for j=1:m_assets
                
            if rand < link_prob
                    
                opn_adjmat(i,j) = 1;
                    
            else
                    
                opn_adjmat(i,j) = 0;
                    
            end
        end
    end
end

%-------------------------------------------------------
%% Transformation and export to Gephi for visualisation
%-------------------------------------------------------
op_vizmat(1:n_banks,n_banks+1:(n_banks+m_assets)) = opn_adjmat;
op_vizmat(n_banks+1:(n_banks+m_assets),1:n_banks) = opn_adjmat';    

% EDGE LIST
op_edgelist_full = adj2edgeL(op_vizmat);
op_edgelist      = op_edgelist_full(1:(sum(sum(opn_adjmat))),:);

header_edges = {'Source' 'Target'};
csvwrite_alt(strcat(fig_output_Gephi,'opn_edgelist_',datestr(datetime('today')),'.csv'),op_edgelist_full,header_edges);

% NODE LIST + ATTRIBUTE

all_op_ids       = linspace(1,n_banks+m_assets,n_banks+m_assets)';
node_type = ones(numel(all_op_ids),1);
node_type(n_banks+1:n_banks+m_assets) = zeros(numel(n_banks+1:n_banks+m_assets),1);

header_nodes = {'Id' 'Type'};
node_data = [all_op_ids, node_type];
csvwrite_alt(strcat(fig_output_Gephi,'opn_nodelist_',datestr(datetime('today')),'.csv'), node_data, header_nodes);

end
            
            
   
