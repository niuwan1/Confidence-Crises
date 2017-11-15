function Results_IBM(fig_output,Results_agg,Results_av,Results_min,Results_max,IBratemat,T,T_sim,results_IBM_format,allsimlabels)

fig_output_IBM = strcat(fig_output,'Results/');
%tol = 1.e-6;

% for t=1:T
%     
%     if abs(TOT_T_matrices(11,t)-TOT_T_matrices(12,t)) < tol
%         TOT_T_matrices(12,t) = TOT_T_matrices(11,t);
%     end
% end

if strcmp(results_IBM_format,'agg')
    Results_plot = Results_agg;
    formatlabel    = '_agg';
elseif strcmp(results_IBM_format,'av')
    Results_plot    = Results_av; % Plot average values
    Results_plot_LB = Results_min; % Plot max and min around average
    Results_plot_UB = Results_max;
    formatlabel    = '_av';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Interbank market %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VOLUMES
%%% Phase 1

figure
subplot(1,2,1) % Interbank loan requests vs actual loans
    if strcmp(results_IBM_format,'agg')
        plot(Results_plot(8,:),'Color','b','LineWidth',1.1) % Total Loan requests
        hold on
        plot(Results_plot(10,:),'Color','k','LineWidth',1.1) % Total Loans
        title('Interbank loan volumes')
        hold off
    elseif strcmp(results_IBM_format,'av')
        boundedline(1:T_sim,Results_plot(8,:),[Results_plot_LB(8,:);Results_plot_UB(8,:)]','alpha',...
                    1:T_sim,Results_plot(10,:),[Results_plot_LB(10,:);Results_plot_UB(10,:)]','alpha');
        title('Interbank loan volumes')
        legend({'Requests','Loans'},'Location','best','FontSize',8)
    end
    grid on;
    legend({'Requests','Loans'},'Location','best','FontSize',8)
subplot(1,2,2) % Hoarding by lenders
    if strcmp(results_IBM_format,'agg')
        plot(Results_plot(9,:),'Color','b','LineWidth',1.1) % Total Loan requests
        title('Lender hoarding')
    elseif strcmp(results_IBM_format,'av')
        %plot(Results_plot(9,:),'Color','b','LineWidth',1.1) % Total Loan requests
        boundedline(1:T_sim,Results_plot(9,:),[Results_plot_LB(9,:);Results_plot_UB(9,:)]','alpha');
        title('Lender hoarding')
    end
grid on;
xlabel('Iteration step','Interpreter','latex')
set(gcf,'renderer','painters');
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'-dpdf',strcat(fig_output_IBM,'IBM_phase1',formatlabel,allsimlabels,'.pdf'));

%%% Phase 2

figure
subplot(1,2,1) % Expected interbank loan repayment vs. Actual repayment
    title('Interbank repayment volumes')
    if strcmp(results_IBM_format,'agg')
        plot(Results_plot(11,:),'Color','b','LineWidth',1.1) % Total Loan requests
        hold on
        plot(Results_plot(12,:),'Color','k','LineWidth',1.1) % Total Loans
        hold off
    elseif strcmp(results_IBM_format,'av')
        boundedline(1:T_sim,Results_plot(11,:),[Results_plot_LB(11,:);Results_plot_UB(11,:)]','alpha',...
                    1:T_sim,Results_plot(12,:),[Results_plot_LB(12,:);Results_plot_UB(12,:)]','alpha');
        legend({'Principal + interest','Repayment'},'Location','best','FontSize',8)
    end
    grid on;
    legend({'Requests','Loans'},'Location','best','FontSize',8)
subplot(1,2,2) % Hoarding by lenders
    title('Expected - Actual repayment')
    if strcmp(results_IBM_format,'agg')
        plot(Results_plot(11,:)-Results_plot(12,:),'Color','b','LineWidth',1.1) % Total Loan requests
    elseif strcmp(results_IBM_format,'av')
        %plot(Results_plot(9,:),'Color','b','LineWidth',1.1) % Total Loan requests
        boundedline(1:T_sim,Results_plot(11,:)-Results_plot(12,:),...
            [Results_plot_LB(11,:)-Results_plot_LB(12,:);Results_plot_UB(11,:)-Results_plot_UB(12,:)]','alpha');
    end
set(gcf,'renderer','painters');
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'-dpdf',strcat(fig_output_IBM,'IBM_phase2',formatlabel,allsimlabels,'.pdf'));
% 
% % Rates
% 
% for t =1:T
%     meanIBrate(t) = mean(nonzeros(IBratemat(:,:,t)));
%     %minIBrate(t) =  min(nonzeros(IBratemat(:,:,t)));
%     %maxIBrate(t) =  max(nonzeros(IBratemat(:,:,t)));    
% end
% 
% figure
% plot(meanIBrate,'Color','k','LineWidth',1.1)
% %hold on
% %plot(minIBrate,'Color','r','LineStyle','--','LineWidth',1.1);
% %hold on
% %plot(maxIBrate,'Color','b','LineStyle','-.','LineWidth',1.1);
% xlabel('Iteration step','Interpreter','latex')
% grid on;
% %legend({'$\bar{r}^{b,t}$','$min\{r^{b,t}\}$','$max\{r^{b,t}\}$'},'Location','best','FontSize',8,'Interpreter','latex')
% set(gcf,'renderer','painters');
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,'-dpdf',strcat(fig_output_IBM,'IBrates.pdf'));


end