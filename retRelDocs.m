function retRelDocs( str, name )

[diction,stop]  = getRepTerms( name );
%% Creating the Term document matrix
m=size(diction,1);
no_of_docs=300;
n=no_of_docs;
TDM=zeros(n,m);
IDF=zeros(m,1);
k=keys(diction);
for i=1:no_of_docs
    temp=containers.Map('KeyType','char','ValueType','int64');
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
C = strsplit(str);
C=C{1};
query=containers.Map('KeyType','char','ValueType','int64');

for j=1:size(C,1)
        word=lower(char(C(j)));
        word=porterStemmer(word);
        if(isKey(stop,word))
            continue;
        end
        word=word(isstrprop(word,'alpha'));
       if (isKey(query,word))
           query(word)=query(word)+1;
       else
           query(word)=1;
       end
end

m=size(TDM,2);
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


end

