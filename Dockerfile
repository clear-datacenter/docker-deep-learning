FROM ubuntu:trusty
MAINTAINER Takenori Nakagawa

# upgrade packages
RUN apt-get update
RUN apt-get upgrade -y

# expose portes
EXPOSE 22

# install dependent packages
RUN apt-get install -y openssh-server curl wget git vim-nox nano build-essential
RUN apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libboost-all-dev libhdf5-serial-dev libatlas-base-dev python-dev libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler

# golang 1.5
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 742A38EE
echo 'deb http://ppa.launchpad.net/evarlast/golang1.5/ubuntu trusty main' | sudo tee /etc/apt/sources.list.d/golang.list

# setup cuda repository
RUN wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.0-28_amd64.deb
RUN dpkg -i cuda-repo-ubuntu1404_7.0-28_amd64.deb; rm -f cuda-repo-ubuntu1404_7.0-28_amd64.deb
RUN apt-get update

RUN apt-get install -y golang
#RUN apt-get install -y cuda

# add user
RUN useradd -m caffe
RUN echo caffe:caffe | chpasswd
RUN gpasswd -a caffe sudo

# set env
ENV PATH /usr/local/cuda-7.0/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH
ENV GOPATH /go
ENV PATH=$PATH:$GOPATH/bin

# set workdir
VOLUME ["/go"]
WORKDIR /go

# install caffe
RUN cd /home/caffe/; git clone https://github.com/BVLC/caffe.git
RUN cd /home/caffe/caffe; cp Makefile.config.example Makefile.config
#RUN cd /home/caffe/caffe; make all

# change owner and group
RUN chown -R caffe /home/caffe
RUN chgrp -R caffe /home/caffe

# set docker init script
ADD init.sh /usr/local/bin/init.sh
RUN chmod u+x /usr/local/bin/init.sh
ENTRYPOINT ["/usr/local/bin/init.sh"]
