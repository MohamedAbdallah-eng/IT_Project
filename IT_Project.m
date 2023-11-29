%% This function prompt the user to enter a text file name and uses 
%%huffman coding with code alphabet = 2 to encode the text file and writes 
%%the code in a file named 'code'. After that, It decodes the code made in 
%%the first part and writes new text in a file named test
%%Note that the file should be in matlab\bin directory and the file name
%%should have its format as well; for example: trial.txt
clear
clc
file_name = input('Please enter File Name: ','s');
file_ID = fopen(file_name,'r');
A = fscanf(file_ID,'%c');
C = unique(A);
prob = zeros(1,length(C));
info = zeros(1,length(C));
H_S = 0;
for i = 1:length(C)
    prob(i) = length(find(A == C(i)))/length(A);
    info(i) = -log2(prob(i));                           % Information of each Symbol
    H_S = H_S - prob(i) * log2(prob(i));                % Entropy
end
[prob_sorted,des_index] = sort(prob,'descend');         %Sorted in descending order

b = zeros(length(C)+1,length(C)-1);
p = prob_sorted;
b(:,1) = [p,0];
%% Huffman Coding
%%First, a matrix with the probabilities and a tree of huffman coding is
%%made. After that, a matrix with the codes in each branch is made.
%%Check b and code in workspace to understand more.
for i = 2:length(C) - 1
    sum = p(end) + p(end - 1);
    p = [p(1:end-2),sum];
    p = sort(p,'descend');
    sum_index = find(p == sum,1);
    b(1:length(p),i) = p;
    b(end,i) = sum_index;
    ind = find(b(:,i) == b(sum_index,i));
    if (ind(1) < sum_index)
        b(end,i) = ind(1);
    end
end
code = strings([length(C),length(C)-1]);
for i = length(C) - 1:-1:2                      % i represents the column number
    if (i == length(C) - 1)
            code(1,i) = "0";
            code(2,i) = "1";
    end
    for j = 1:length(C)-i+1
        if (j == b(end,i))
            code(length(C)-i+1,i-1) = strcat(code(j,i),num2str(0));
            code(length(C)-i+2,i-1) = strcat(code(j,i),num2str(1));
        else
            if (j == 1)                         % j represents the row number
                index = find(b(:,i-1) == b(j,i),1);
                code(index,i-1) = code(j,i);
            elseif (b(j,i) == b(j-1,i) && (j-1) ~= b(end,i)) 
               index = find(b(:,i-1) == b(j,i));
               for k = 2:length(index)
                   if (code(index(k),i-1) == "")
                       code(index(k),i-1) = code(j,i);
                       break;
                   end
               end
            else
            index = find(b(:,i-1) == b(j,i),1);
            code(index,i-1) = code(j,i);
            end
        end
    end
end
%% Making the code dictionary
%%resorting the codes as the order of the symbols
coded_symbol = strings([1,length(C)]);
for i = 1:length(C)
    coded_symbol(des_index(i)) = code(i,1);                     
end
%% re-writing File
coding = "";
for L = 1:length(A)
   inx = find(C == A(L));
   coding = strcat(coding,coded_symbol(inx));
end

%% Writing Code in a File
fid = fopen('Code.txt','wt');
fprintf(fid,'%s',coding);
fclose(fid);

%% Efficiency
L_avg = 0;
for i = 1:length(C)
    L_avg = L_avg + strlength(coded_symbol(i)) * prob(i);
end
Efficiency = H_S/L_avg;

%% Compression Ratio
 Compression_Ratio = strlength(coding)/(strlength(A)*8);
 
%% Decoding
i = 1;
m = 1;
New_text = "";
while (i <= strlength(coding))
    op = extractBetween(coding,m,i);
    op2 = find(coded_symbol == op);
    if (isempty(op2))
        i = i + 1;
        continue;
    end
    k = i - m + 1;
    New_text = New_text + C(op2); 
    m = m + k;
    i = i + 1;
end

%% Creating a New file and writing the decoded symbols in it
fid1 = fopen('test.txt','wt');
fprintf(fid1,'%s',New_text);
fclose(fid1);

%% Comparing the new text with the original text
Compare = strcmp(A,New_text);           % Note that A is the original text
    
