function [ diction, stop ] = getRepTerms( name )
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
    x=[name '\' num2str(i) '.txt'];
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


end

