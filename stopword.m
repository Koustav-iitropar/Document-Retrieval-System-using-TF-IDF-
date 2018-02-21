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
 
prompt = 'What is the high threshold value? ';
high = input(prompt);
prompt = 'What is the low threshold value? ';
low = input(prompt);
