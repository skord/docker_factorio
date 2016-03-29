FROM phusion/passenger-full:0.9.18
RUN apt-get update && apt-get -y upgrade
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /opt
RUN curl -k -L -O https://www.factorio.com/get-download/0.12.29/headless/linux64
RUN tar xvfz linux64
RUN mkdir -p /opt/factorio/mods
RUN chown -R app:app /opt/factorio
#WORKDIR /opt/factorio
#VOLUME /opt/factorio/saves
RUN rm -f /etc/service/nginx/down
ADD facpad/Gemfile facpad/Gemfile.lock /home/app/facpad/
WORKDIR /home/app/facpad
RUN bundle
ADD facpad /home/app/facpad
RUN chown -R app:app /home/app/facpad
ADD default_site.conf /etc/nginx/sites-available/default
ADD 00_app_env.conf /etc/nginx/main.d/
RUN mkdir -p /etc/service/factorio
ADD factorio_runit.sh /etc/service/factorio/run
RUN chmod +x /etc/service/factorio/run
ADD rc.local /etc/rc.local
RUN chmod 755 /etc/rc.local
ADD app_sudoer /etc/sudoers.d
RUN chmod 0440 /etc/sudoers.d/app_sudoer
