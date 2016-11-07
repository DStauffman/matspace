clc; close all; clear;

% inputs
num = 5e6;
saveplots = true;

% initializations
x = zeros(num,1);

% calculations
for i = 1:num
    total = 0;
    anti_air = ceil(6*rand);
    while anti_air ~= 1
        total = total + ceil(6*rand);
        anti_air = ceil(6*rand);
    end
    x(i) = total;
end

% times lost
won = length(find(x > 15));
tied = length(find(x == 15));
lost = length(find(x < 15));

% plot
figure;
[y_data,x_data] = hist(x,max(x));
bar(x_data,100*y_data/num);
xlim([0 50]);
grid on;
xlabel('Total bombing score');
ylabel('percentage');
title(['Bombing Run Total Damage - based on ',num2str(num),' iterations']);
% annotate graph
text(30.5,16.5,['Max  = ',num2str(max(x))]);
text(30.5,15.5,['Min  = ',num2str(min(x))]);
text(30.5,14.5,['Mean = ',num2str(mean(x),'%.2f')]);
text(30.5,13.5,['Std  = ',num2str(std(x),'%.2f')]);
text(30.5,12.5,['Won:  ',num2str(100*won/num,'%.2f'),' %']);
text(30.5,11.5,['Tied:  ',num2str(100*tied/num,'%.2f'),' %']);
text(30.5,10.5,['Lost: ',num2str(100*lost/num,'%.2f'),' %']);
if saveplots
    print('-dpng','Bombing Run Histogram.png');
end