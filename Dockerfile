FROM nsml/default_ml:latest

LABEL maintainer="syschat <syschat@naver.com>"

# Update
RUN apt-get update
RUN apt-get -y install default-jre
RUN apt-get -y install default-jdk
RUN apt-get -y install g++ 
RUN apt-get -y install curl

RUN pip install pip --upgrade

#install konlpy 
RUN pip install konlpy  
