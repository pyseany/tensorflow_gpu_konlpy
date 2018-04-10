FROM nsml/default_ml:latest

LABEL maintainer="syschat <syschat@naver.com>"

# Update
RUN apt-get update
RUN apt-get -y install default-jre
RUN apt-get -y install default-jdk
RUN apt-get -y install g++ 
RUN apt-get -y install curl

RUN python3.6 -m pip install pip --upgrade

#install konlpy mecab
RUN pip3 install konlpy  
RUN curl -fSsL -O https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh && \
    chmod +x mecab.sh && \
    ./mecab.sh
