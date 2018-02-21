%% Creating the dataset for stop words
clear all
stop=containers.Map('KeyType','char','ValueType','int64');
fileID = fopen('stopwords.txt');
C = textscan(fileID,'%s');
C=C{1};
m=size(C,1);
for j=1:m
    word=lower(char(C(j)));
    if (~isKey(stop,word))
           stop(word)=1;
    end
end
 fclose(fileID);
%% Low and high values for thresholding 
prompt = 'What is the high threshold value? ';
high = input(prompt);
prompt = 'What is the low threshold value? ';
low = input(prompt);

%% Creating of the dictionary
diction = containers.Map('KeyType','char','ValueType','int64');
no_of_docs=300;
for i=1:no_of_docs
    x=['corpus\' num2str(i) '.txt'];
    fileID = fopen(x);
    C = textscan(fileID,'%s');
    C=C{1};
    m=size(C,1);
    for j=4:m
        word=lower(char(C(j)));
        word=porterStemmer(word);
        if(isKey(stop,word))
            continue;
        end
        word=word(isstrprop(word,'alpha'));
       if (isKey(diction,word))
           diction(word)=diction(word)+1;
       else
           diction(word)=1;
       end
    end
    fclose(fileID);
end
%% Removing the words above the threshold and lower the threshold
k=keys(diction);
val=values(diction);
for i=1:length(diction)
    if val{i}<low || val{i}>high
        remove(diction,k{i});
    end
end
%% Saving the dictionary
k=keys(diction);
fileID=fopen('Dictionary.txt','w');
for i=1:length(diction)
    fprintf(fileID,'%s\n',k{i});
end
fclose(fileID);
%% Creating the Term document matrix
m=size(diction,1);
no_of_docs=300;
n=no_of_docs;
TDM=zeros(n,m);
IDF=zeros(m,1);
k=keys(diction);
val=values(diction);
for i=1:no_of_docs
    temp=containers.Map('KeyType','char','ValueType','int64');
    x=['corpus\' num2str(i) '.txt'];
    fileID = fopen(x);
    C = textscan(fileID,'%s');
    C=C{1};
    m=size(C,1);
    for j=4:m
        word=lower(char(C(j)));
        word=porterStemmer(word);
        if(isKey(stop,word))
            continue;
        end
        word=word(isstrprop(word,'alpha'));
       if (isKey(temp,word))
           temp(word)=temp(word)+1;
       else
           temp(word)=1;
       end
    end
    
    
    for j=1:length(diction)
        if(isKey(temp,k{j}))
            TDM(i,j)=temp(k{j});
            IDF(j)= IDF(j)+1;
        else
            TDM(i,j)=0;
        end
    end
     fclose(fileID);
end

for j=1:length(diction)
IDF(j)=1+log10(no_of_docs/IDF(j));
end

%% Creating the computation table
table=TDM;
[m,n]=size(TDM);
for i=1:m
    for j=1:n
        table(i,j)=table(i,j)*IDF(j);
    end
end

%% Taking The query
prompt = 'What is the query? ';
str = input(prompt);
C = strsplit(str);
C=C{1};
query=containers.Map('KeyType','char','ValueType','int64');

for j=1:m
        word=lower(char(C(j)));
        word=porterStemmer(word);
        if(isKey(stop,word))
            continue;
        end
        word=word(isstrprop(word,'alpha'));
       if (isKey(query,word))
           diction(query)=diction(query)+1;
       else
           diction(query)=1;
       end
end

res=zeros(m,1);
 
for i=1:no_of_docs
for j=1:length(diction)
        if(isKey(query,k{j}))
            res(i)=res(i)+table(i,j);
        end
end 
end
[M,I] = max(res);

fprintf('The most relevent document is %d',I);