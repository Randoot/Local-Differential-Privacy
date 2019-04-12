%function C_list = Search_Salient_points(Ds_i)
%clear all
Records =load('Senders and recievers.csv');
[~,j]=size(Records);

selected_user_number =400;
for user=1:selected_user_number %% Determine the number of users up to 400
Try(1,:) = Records(user,:); %% use to select user
Try(2,:)= [1 2 3 4 5 6 7 8 9 10];
Clist = [];
[~,n] = size(Try); 
% claculate first order derivative for first element in stream
 Der(1,1) = Try(1,1)-0; %% The derevative value
 Der(2,1) = Try(2,1);   %% The times stamps
 Der(3,1) = Try(1,1);   %% the xi value of the data stream at time stamp i
 % claculate first order derivative for the rest of element in stream
for i=2:n
    Der(1,i)= Try(1,i)-Try(1,i-1);
    Der(2,i)= Try(2,i);
    Der(3,i)= Try(1,i);
end
% End of calculating first order derivative

% Excluding derviative valuse of ZERO
 h=1;
for i=1:n
     if Der(1,i)~=0
      C_list(1,h)=Der(1,i); %% The derevative value
      C_list(2,h)=Der(2,i); %% The times stamps
      C_list(3,h)=Der(3,i); %% the xi value of the data stream at time stamp i
      h =h +1;
     end
end   

% Selecting points in biginning of an ascending or descending 
[~,n]=size(C_list);
while 1
    interval_min = 100;
    for h =2:n-1
        % Pre element
        Dx_pre =C_list(1,h-1);
        T_pre=  C_list(2,h-1);
        %current element
        Dx_cur=C_list(1,h);
        T_cur= C_list(2,h);
        %next Element
        Dx_next= C_list(1,h+1);
        T_next=  C_list(2,h+1);
        if (Dx_pre>0 &&  Dx_cur>0 &&Dx_next >0) || (Dx_pre<0 &&  Dx_cur<0 &&Dx_next<0)
            %display('First if increasing or decreasing');
            interval_cur = (abs(T_cur-T_pre)+abs(T_cur-T_next));
            % display('| absoulte interval_cur|');
            if (interval_cur < interval_min)
            %   display('Second if interval cur < interval min ');
              %  display('interval min is');
               interval_min = interval_cur;
               t_min =h;
            end
        end
    end
    if (interval_min == 100)
       % display('BREAK');
       break
    end
    C_list(1,t_min)=0;
    %display('Element at index t-min is zero');
    C_list(1,t_min);
    %display('Remove element');
    
end

% Removing points that were assigned zero in the previous phase
%  (C_list)  
 [~,n]=size (C_list);
 h=1;
 for i=1:n
     if (C_list(1,i))~=0
     Selected_SP(1,h)= C_list(1,i);
     Selected_SP(2,h)=C_list(2,i);
     Selected_SP(3,h)=C_list(3,i);
     h=h+1;
     end
 end
 % Selected_SP;
 % All the work will focus on Selected_SP(3,:)
 % The first row is the first order derivative
 % The second rwo is the time stamp
 % The third row is the valuse of the salient point to which we add noise.
 

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% parameters to be changed : Epsilon + Alpha
Epsilon = 2;
Alpha =0.5;
%Beta =0.5;
 % Second phase partitioning Epsilon
 % uniform partitioning
 [~,n]=size(Selected_SP);
 for i=1:n 
    Selected_SP(4,i)= (Epsilon/n);
 end
%Selected_SP(4,:)
% adaptive partitioning
%% fifth row represents Adaptive partitioning

%  Uniform_Up=0;  % must uncomment on first use to clear garbage values.
%  Adaptive_Up=0;
%  Uniform_Noise=0;
%  Adaptive_Noise=0;
%  Noisy_stream= zeros;
 
 [~,n]=size(Selected_SP);
 Selected_SP(5,1) = Selected_SP(2,1);
 for i=2:n-1
     Uniform_Up =abs(Selected_SP(2,i)-Selected_SP(2,i-1))+ abs(Selected_SP(2,i)-Selected_SP(2,i+1));
     Fraction = Uniform_Up/2;
     Temporal_scale = Fraction.^Alpha;
     Selected_SP(5,i)= Temporal_scale; 
 end
 % The last element in the selected points does not have next 
     Uniform_Up =abs(Selected_SP(2,n)-Selected_SP(2,n-1));
     Fraction = Uniform_Up/2;
     Temporal_scale = Fraction.^Alpha;
     Selected_SP(5,n)= Temporal_scale;
%  Selected_SP(:,:)
  
 temporal_sum=0;
 for i=1:n
     temporal_sum = temporal_sum+ Selected_SP(5,i);
 end
 
 for i=1:n
   Selected_SP(5,i)= Epsilon .*(Selected_SP(5,i)/temporal_sum);
 end
 
%Selected_SP(:,:)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % calculating laplace noise
%% must have high values for epsilon
%Epsilon = 2; % Start from 1.00 ,2.00
Scale_b =0.2; %%% THE increase of this parameter increases the noise
Mean_Mue = 0.8; %%% Also try 0.9 , The increase beyond 2 decreases the noise to e-
s_max = max(Records1(:));
s_min= min(Records1(:));
%Delta_s = s_max-s_min; %% only when data sensitivity is very low
Delta_s = 0.15;  %% Also try 0.10, the decrease of this paramets increases the noise
[m,n]=size(Selected_SP);
% P1=pdf('Normal',Delta_s/Selected_SP(4,1),Mean_Mue,Scale_b)


for i=1:n
   Uniform_Up= Delta_s/Selected_SP(4,i);   % Delta over uniform epsilon
   Adaptive_Up = Delta_s/Selected_SP(5,i);   % Delta over adaptive Epsilon
   Uniform_Noise = pdf('Normal',Uniform_Up,Mean_Mue,Scale_b);
   Adaptive_Noise = pdf('Normal', Adaptive_Up,Mean_Mue,Scale_b);
   Noisy_stream (1,i) = Selected_SP(3,i)+ Uniform_Noise;
   Noisy_stream (2,i) = Selected_SP(3,i)+ Adaptive_Noise;
end

  Noisy_stream (3,:)= Selected_SP(2,:);
 %Noisy_stream
 %%%% PHASE 3 Reconstructing the original data stream

%% Fist : Uniform distribution + linear Estimation
[~,n]= size(Noisy_stream);
 for i=1:n-1
     a(1,i)= ((Noisy_stream(1,i+1)- Noisy_stream(1,i))/ (Noisy_stream(3,i+1)-Noisy_stream(3,i)) );
     a(2,i)= ((Noisy_stream(2,i+1)- Noisy_stream(2,i))/ (Noisy_stream(3,i+1)-Noisy_stream(3,i)) );
     b(1,i)=  Noisy_stream(1,i)- a(1,i) .*Noisy_stream(3,i);
     b(2,i)=  Noisy_stream(2,i)- a(1,i) .*Noisy_stream(3,i);
 end
     a(1,n)= Noisy_stream(1,n)/Noisy_stream(3,n); % claculate nosie for the last element
     b(1,n)= Noisy_stream(1,n)- a(1,n).*Noisy_stream(3,n);
     a(2,n)= Noisy_stream(2,n)/Noisy_stream(3,n);
     b(2,n)= Noisy_stream(2,n)- a(1,n).*Noisy_stream(3,n);
 

 %% plot the linear estimated curve
 %% First plot the original curve
% ylabel('user calls');
% xlabel('days');

for i = 1:n
y(1,i) = (a(1,i).*Noisy_stream(3,i))+b(1,i); %% reconstructed value of xd in uniform privacy +linear
y(2,i) = (a(1,i).*Noisy_stream(3,i))+b(1,i); %% reconstructed value of xd in adaptive orivacy + linear
end

Actual_matrix(user,:)= Selected_SP(3,:);
Uniform_reconstructed_matrix(user,:)=y(1,:);
Adaptive_reconstructed_matrix (user,:)= y(2,:);   


end

[m,n]=size(Uniform_reconstructed_matrix);
Average_Uniform_mtrix(1,n)= zeros;
Average_Adaptive_matrix(1,n)=zeros;
for timestamp =1:n
    for users=1:m
    Average_Uniform_mtrix(1,timestamp)= Average_Uniform_mtrix(1,timestamp)+ Uniform_reconstructed_matrix(users,timestamp);
    Average_Adaptive_matrix(1,timestamp)= Average_Adaptive_matrix(1,timestamp)+ Adaptive_reconstructed_matrix(users,timestamp);
    end
   AVG_est_uniform(1,timestamp) = ((1/selected_user_number).*  Average_Uniform_mtrix(1,timestamp));
   AVG_est_adaptive(1,timestamp) = ((1/selected_user_number).*  Average_Uniform_mtrix(1,timestamp));
   
end    

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%5claculating the average %%%%%%%%%
% 
% for j=1:10
% Avg_Xd(1,j) = Avg_Xd(:,j) + Try(1,j);
% Avg_uniform(1,j) = Avg_uniform(1,j) +y(1,j);
% Avg_adaptive(1,j) = Avg_adaptive(1,j) +y(2,j);
% end
% 
% end
% AVG_est_Xd = Avg_Xd/ number_users
% AVG_est_uniform = Avg_uniform/number_users
% AVG_est_adaptive = Avg_adaptive/number_users
% 
% %%%% Uniform error 
% sum1 = 0;
% for d=1:10
%     summation_d(1,d)= ( AVG_est_Xd(1,j)- AVG_est_uniform(1,d) )/ AVG_est_Xd(1,j);
%     sum1 =sum + summation_d(1,d);
% end
% Uniform_error = (sum1/10) 
% 
% sum = 0;
% for d=1:10
%     summation_d(1,d)= (AVG_est_adaptive(1,d)- AVG_est_Xd(1,j) )/ AVG_est_Xd(1,j);
%     sum =sum + summation_d(1,d);
% end
% Adaptive_error = (sum/10)

disp('Finished');
