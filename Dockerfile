FROM nsml/default_ml:latest

LABEL maintainer="syschat <syschat@naver.com>"

# Update
RUN apt-get update
RUN apt-get install g++ openjdk-7-jdk python-dev python3-dev
RUN apt-get install curl
RUN python3.6 -m pip install pip --upgrade

#install konlpy mecab
RUN pip3 install konlpy  
RUN curl -fSsL -O https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh && \
    chmod +x mecab.sh && \
    ./mecab.sh
