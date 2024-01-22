clear
close all;
clc
%% Encoding the file using part_1 code
IT_Project;
%% opening the encoded file
fid = fopen('Code.txt','r');
C = fscanf(fid,'%1d');          %%1d to get each number as integer alone in a vector element
fclose(fid);D
msg = C';
%% Hamming Encoding
for l = 1:4
if rem(length(msg),4) == 0
encode_hamm = encode(msg,7,4,'hamming/binary'); %%n = 2^m - 1 = 7 so m = 3 and k = 7 - 3 = 4
break;
end
msg = [msg(1:end-1)];
end
%% Tranmitting through BSC and calculating BER
prob = 0:0.01:0.2;
for i = 1:length(prob)
ndata_encoding{i} = bsc(encode_hamm,prob(i));           %%encoded data with error
ndata_non{i} = bsc(msg,prob(i));                         %%data with error
ndata_decoded{i} = decode(ndata_encoding{i},7,4,'hamming/binary');
[number1 , BER_encode(i)] = biterr(ndata_decoded{i},msg);
[number2 , BER_non(i)] = biterr(ndata_non{i},msg);       %%decoded isn't needed here since the data hasn't been encoded
end
figure(1)
plot(prob*100,BER_non);
hold on;
plot(prob*100,BER_encode);
legend('BER without encoding','BER channel encoded');
title('BER vs Probability of error');
xlabel('Probability of error (%)');
ylabel('Bit Error Rate');

%% Part 2
i = 1;
for m = 2:10
    n(i) = 2^m - 1;
    k(i) = n(i) - m;
    msg1 = msg;
    for l = 1:k(i)
        if rem(length(msg1),k(i)) == 0
        msg_encoded = encode(msg1,n(i),k(i),'hamming/binary');
        break;
        end
        msg1 = [msg1(1:end-1)];
    end
    encoded_error = bsc(msg_encoded,0.01);
    ndata_decoded2 = decode(encoded_error,n(i),k(i),'hamming/binary');
    [number , BER(i)] = biterr(ndata_decoded2,msg1);
    if BER(i) > 8e-3
        break;
    end
    BER_accepted(i) = BER(i); 
    i = i + 1;
end
%%code rate efficiency increases as m increases as the number of redundant
%%bits added to the message decreases
n_acc = n(length(BER_accepted));
k_acc = k(length(BER_accepted));
code_rate_efficiency = (k_acc/n_acc)*100;
fprintf('The Hamming Coding with highest possible efficiency is (%d,%d) hamming code\n',n_acc,k_acc);
fprintf('The BER for this hamming code = %d\n',BER_accepted(end));
fprintf('The Code Rate Efficiency for this hamming code = %f%%\n',code_rate_efficiency);