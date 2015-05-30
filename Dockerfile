FROM phusion/baseimage

# Initialize mysql password to abc123
#RUN echo 'mysql-server-5.5 mysql-server/root_password password abc123'|debconf-set-selections
#RUN echo 'mysql-server-5.5 mysql-server/root_password_again password abc123'|debconf-set-selections

# Install node, mysql, etc.
RUN curl -sL https://deb.nodesource.com/setup_dev | bash -
RUN apt-get install -y unzip build-essential nodejs ruby2.0 ruby2.0-dev git \
                       libsqlite3-dev libmysqlclient-dev mysql-server \
                       nginx

# Make sure bower is globally available
RUN npm install -g bower

# Force system to use ruby 2.0
RUN ln -sf /usr/bin/ruby2.0 /usr/bin/ruby
RUN ln -sf /usr/bin/gem2.0 /usr/bin/gem

# Install bundler using ruby 2.0
RUN gem install bundler

# Install mailcatcher
RUN gem install mailcatcher

# Install config override for mysql
#ADD files/mysql.cnf /etc/mysql/conf.d/override.cnf

# Ensure remote access is enabled for MySQL
RUN /etc/init.d/mysql start && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    /etc/init.d/mysql stop

# (Use prefix zX. to explicitly order startup files)
ADD files/runit/mailcatcher.sh /etc/service/z0.mailcatcher/run
ADD files/runit/nginx.sh /etc/service/z1.nginx/run
RUN find /etc/service -name "run" -type f -exec chmod a+x {} \;

# Add rc.local
ADD files/rc.local /etc/rc.local
RUN chmod a+x /etc/rc.local

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
