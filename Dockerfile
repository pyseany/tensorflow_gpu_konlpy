FROM nsml/default_ml:latest

LABEL maintainer="syschat <syschat@naver.com>"

# Update
RUN apt-get update
RUN apt-get -y install default-jre
RUN apt-get -y install default-jdk
RUN apt-get -y install g++ 
RUN apt-get -y install curl
RUN apt-get install -y wget build-essential autotools-dev automake libmecab2 libmecab-dev

RUN pip install pip --upgrade

#install konlpy 
RUN pip install konlpy  
RUN pip install JPype1-py3

