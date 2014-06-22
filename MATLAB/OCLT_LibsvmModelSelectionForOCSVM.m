function [bestf1,bestg] = OCLT_LibsvmModelSelectionForOCSVM(A,rejf,validA,gmin,gmax,v,gstep)
% Model Selection for OCSVM (g only)

%% about the parameters
if nargin < 7
    gstep = 5;
end
if nargin < 6
    v = 5;
end
if nargin < 5
    gmin = 0;
    gmax = 300;
end

%% X:c Y:g cg:CVaccuracy
G = gmin:gstep:gmax;

eps = 1e-1;
%% record acc with different g,and find the bestacc

bestg = gmin;
bestf1 = 0;
f1 = zeros(length(G), 1);
fn = zeros(length(G), 1);
fp = zeros(length(G), 1);
for i = 1:1:length(G)

        cmd = ['-s 2 -n ',num2str(rejf),' -g ',num2str(G(i))];
        model = LC_LibsvmC(A, cmd);
        res = validA * model;
        e = dd_error(res);
        fn(i) = e(1);
        fp(i) = e(2);
        %f1(i) = dd_f1(res);
        f1(i) = dd_auc(dd_roc(validA, model));
        if(fn(i) > rejf*1.5 || fp(i) > 0.5)
            %continue;
        end        
      
        if f1(i) > bestf1
            bestf1 = f1(i);
            bestg = G(i);
        end                           
end

% msgbox(num2str(bestg))
% figure
% plot(G, f1, 'k');
% hold on
% plot(G, fn, 'r');
% plot(G, fp, 'b');

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