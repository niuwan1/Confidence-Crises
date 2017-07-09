function [banksfail] = Results_failures(fig_output,n_banks,IBN_adjmat,OPN_adjmat,banksfail,FailedBanks,FailCount,num_IA,t,T)

fig_output_F = strcat(fig_output,'Results/');

banksfail = banksfail(FailedBanks);
NumFails  = numel(banksfail);
cum_Fails = cumsum(FailCount);

numnodes = n_banks*ones(1,T) - cum_Fails(1:T);

numedges = zeros(1,T);
density  = zeros(1,T);
avdegree = zeros(1,T);

capitalshortfall_vec = zeros(NumFails,T);

for i=1:NumFails
    capitalshortfall_vec(i,banksfail(i).failtime) = banksfail(i).balancesheet.liabilities.capital(banksfail(i).failtime,3);
end

capitalshortfall = abs(sum(capitalshortfall_vec));

% Number of failures

figure
subplot(1,2,1)
    plot(FailCount)
    hold on
    plot(cumsum(FailCount))
    xlabel('Iteration step','Interpreter','latex')
    grid on;
    legend({'\# of Failures','\# of Failures (cumulative)'},'Location','best','FontSize',8,'Interpreter','latex')
subplot(1,2,2)
    plot(capitalshortfall)
    hold on
    plot(cumsum(capitalshortfall))
    xlabel('Iteration step','Interpreter','latex')
    grid on;
    legend({'Capital shortfall','Capital shortfall (cumulative)'},'Location','best','FontSize',8,'Interpreter','latex')
set(gcf,'renderer','painters');
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'-dpdf',strcat(fig_output_F,'failures.pdf'));


% Graphing changing network structure due to ABM

for t=1:T
    numedges(t) = sum(sum(IBN_adjmat(:,:,t)));
    
    mu_A_vec(t,:) = sum(OPN_adjmat(:,:,t),2); 
    mu_A(t) = mean(mu_A_vec(t,:));
    
    M(t) = nnz(mu_A_vec(t,:));
    
    mu_B_vec(t,:) = sum(OPN_adjmat(:,:,t)); 
    mu_B(t) = mean(mu_B_vec(t,:));
    
    N(t) = nnz(mu_B_vec(t,:));
    
end    

density  = 2*numedges./(numnodes.*(numnodes-ones(1,T)));
avdegree = 2*numedges./numnodes;

%%%   
figure
subplot(1,3,1)
    plot(numedges)
    grid on;
    title('Number of edges','Interpreter','latex')
    xlabel('Iteration step','Interpreter','latex')
subplot(1,3,2)
    plot(density)
    grid on;
    title('Network density','Interpreter','latex')
    xlabel('Iteration step','Interpreter','latex')
subplot(1,3,3)
    plot(avdegree)
    grid on;
    title('Average degree','Interpreter','latex')
    xlabel('Iteration step','Interpreter','latex')
set(gcf,'renderer','painters');
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'-dpdf',strcat(fig_output_F,'IBnetworkmeasures.pdf'));


figure
subplot(2,2,1)
    plot(mu_A)
    grid on;
    title('$\mu_{A}$ (Average diversification)','Interpreter','latex')
    xlabel('Iteration step','Interpreter','latex')
subplot(2,2,2)
    plot(mu_B)
    grid on;
    title('$\mu_{B}$','Interpreter','latex')
    xlabel('Iteration step','Interpreter','latex')
subplot(2,2,3)
    plot(N)
    hold on;
    plot(M)
    legend({'\# of active banks','\# of active assets'},'Location','best','FontSize',8,'Interpreter','latex')
    xlabel('Iteration step','Interpreter','latex')
subplot(2,2,4)
    plot(N./M)
    grid on;
    title('$N/M$ (Crowding parameter)','Interpreter','latex')
    xlabel('Iteration step','Interpreter','latex')
set(gcf,'renderer','painters');
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'-dpdf',strcat(fig_output_F,'OPnetworkmeasures.pdf'));

end