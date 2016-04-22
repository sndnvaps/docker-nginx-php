FROM ubuntu:14.04

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

# Nginx-PHP Installation
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim curl wget build-essential python-software-properties git
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository  ppa:ondrej/php
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes \
		libcurl4-gnutls-dev libpng-dev libmcrypt-dev libsqlite3-dev \
		php7.0 php7.0-fpm php7.0-mysql \
		php7.0-cli php7.0-pgsql php7.0-sqlite php7.0-curl \
		php7.0-gd php7.0-mcrypt php7.0-intl php7.0-imap php7.0-tidy

# Change your php settings in php.ini and copy it to the right path.
COPY php.ini /usr/local/etc/php/php.ini
RUN  ln -s /usr/sbin/php-fpm7.0 /usr/sbin/php-fpm

# install nginx 
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx
COPY nginx.conf /etc/nginx/nginx.conf

# setup supervisord 
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y supervisor sudo
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# setup sshd
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y	ssh openssh-server pwgen
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
#COPY ./run.sh /run.sh
#RUN chmod 0755 /run.sh

RUN useradd admin
RUN echo "admin:admin" | chpasswd
RUN echo "admin   ALL=(ALL)       ALL" >> /etc/sudoers

RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -y
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -y


# setup log path 
RUN mkdir /var/run/sshd
# log for supervisor 
RUN mkdir -p /var/log/supervisor
#set up sock path  for php-fpm7.0
RUN mkdir -p /run/php
# clean 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#setup for website 
RUN mkdir -p	/www
RUN mkdir -p	/www-data

COPY www/index.php /www/index.php	
#set up ssh user 
#CMD ["/run.sh"]



VOLUME ["/www"]
EXPOSE 22 80 443 
CMD ["/usr/bin/supervisord"]
