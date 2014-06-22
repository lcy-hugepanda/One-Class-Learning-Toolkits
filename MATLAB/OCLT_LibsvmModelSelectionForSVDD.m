function [best,bestg] = LC_LibsvmModelSelectionForSVDD(A,rejf,validA,isNeedPlot, gmin,gmax,v,gstep)
% Model Selection for SVDD (g only)

%% about the parameters
if nargin < 8
    gstep = 0.3;
end
if nargin < 7
    v = 5;
end
if nargin < 6
    gmin = 0.05;
    gmax = 7;
end

%% X:c Y:g cg:CVaccuracy
G = gmin:gstep:gmax;

eps = 1e-1;
%% record acc with different g,and find the bestacc

bestg = gmin;
best = 0;
bestmodel = OCLT_AlgoLibsvmSVDD(A, [' -g ', num2str(gmin)], rejf);

f1 = zeros(length(G), 1);
fn = zeros(length(G), 1);
fp = zeros(length(G), 1);
auc = zeros(length(G), 1);
prec = zeros(length(G), 1);
recl = zeros(length(G), 1);
for i = 1:1:length(G)
%         cmd = ['-s 2 -n ',num2str(rejf),' -g ',num2str(G(i))];
%         model = LC_LibsvmC(A, cmd);
        model = OCLT_AlgoLibsvmSVDD(A, [' -g ', num2str(G(i))], rejf);

        [e,f] = dd_error(validA , model);
        fn(i) = e(1);
        fp(i) = e(2);
        prec(i) = f(1);
        recl(i) = f(2);
        f1(i) = dd_f1(validA , model);
        auc(i) = dd_auc(dd_roc(validA , model));
        
        if(prec(i) < 1-4*rejf || recl(i) < 1-4*rejf)
            continue;
        end        
      
        crit = auc(i) ;
        if crit > best*1.02
            best = crit;
            bestg = G(i);
            bestmodel = model;
        end                           
end

if (1 == isNeedPlot)
    a=get(0);
    figure('position',a.MonitorPositions);
    subplot(2,2,1:2)
    p_1 = plot(G, auc, 'r');
    hold on
    p_2 = plot(G, f1, 'b');   
    p_3 = plot(G, fn, 'r:');
    p_4 = plot(G, fp, 'b:');
	p_5 = plot(G, prec, 'r--');
    p_6 = plot(G, recl, 'b--');
    plot([bestg, bestg],[0, 1]);
    legend([p_1 p_2 p_3 p_4 p_5 p_6], 'AUC', 'F1','FP','FN','Prec','Recl');
    
    subplot(2,2,3)
    scatterd(A); hold on;
    plotc(bestmodel);
    
    subplot(2,2,4)
    scatterd(validA); hold on;
    plotc(bestmodel);
end

% %% to draw the acc with different c & g
% figure;
% [C,h] = contour(X,Y,cg,70:accstep:100);
% clabel(C,h,'Color','r');
% xlabel('log2c','FontSize',12);
% ylabel('log2g','FontSize',12);
% firstline = 'SVC参数选择结果图(等高线图)[GridSearchMethod]'; 
% secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
%     ' CVAccuracy=',num2str(bestacc),'%'];
% title({firstline;secondline},'Fontsize',12);
% grid on; 
% 
% figure;
% meshc(X,Y,cg);
% % mesh(X,Y,cg);
% % surf(X,Y,cg);
% axis([cmin,cmax,gmin,gmax,30,100]);
% xlabel('log2c','FontSize',12);
% ylabel('log2g','FontSize',12);
% zlabel('Accuracy(%)','FontSize',12);
% firstline = 'SVC参数选择结果图(3D视图)[GridSearchMethod]'; 
% secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
%     ' CVAccuracy=',num2str(bestacc),'%'];
% title({firstline;secondline},'Fontsize',12);