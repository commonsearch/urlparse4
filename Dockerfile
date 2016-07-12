FROM debian:jessie

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
	curl \
	automake \
	gcc \
	g++ \
	make \
	libtool \
	ca-certificates \
	python-pip \
	python-dev \
	python-numpy \
	bzip2 \
	git \
	pkg-config \
	liburiparser-dev \
	vim

RUN mkdir -p /cosr/urlparse4

# Upgrade pip
RUN pip install --upgrade --ignore-installed pip

ADD requirements.txt /requirements.txt

# Install Cython first to be able to install other dependencies from git
RUN grep -i "^Cython\=" /requirements.txt | xargs -n1 pip install

RUN pip install -r requirements.txt

RUN cd /tmp && \
	git clone --recursive https://github.com/mitghi/cyuri && \
	cd ./cyuri/liburi && \
	autoreconf -i && \
	./configure --prefix=/usr/local && \
	make && \
	make install && \
	cd .. && \
	CPPFLAGS=-I/usr/local/include/liburi make && \
	cp cyuri.so /usr/lib/python2.7/ && \
	ldconfig

ADD Makefile /Makefile
