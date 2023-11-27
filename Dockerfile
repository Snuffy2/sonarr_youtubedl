FROM python:3.12-slim-bookworm
#LABEL maintainer="Martin Jones <whatdaybob@outlook.com>"

RUN pip3 install --upgrade pip
RUN apt-get update && apt-get upgrade -y

# Update and install ffmpeg
RUN apt-get install -y --no-install-recommends git curl ffmpeg

# Copy and install requirements
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir --upgrade -r requirements.txt

# create abc user so root isn't used
RUN \
	groupmod -g 1000 users && \
	useradd -u 911 -U -d /config -s /bin/false abc && \
	usermod -G users abc && \
# create some files / folders
	mkdir -p /config /app /sonarr_root /logs && \
	touch /var/lock/sonarr_youtube.lock

# add volumes
VOLUME /config
VOLUME /sonarr_root
VOLUME /logs

# add local files
COPY app/ /app

# update file permissions
RUN \
    chmod -f a+x \
    /app/sonarr_youtubedl.py \
    /app/utils.py \
    /app/config.yml.template

# ENV setup
ENV CONFIGPATH /config/config.yml

CMD [ "python3", "-u", "/app/sonarr_youtubedl.py" ]
#CMD [ "tail", "-f", "/dev/null" ]
