#
# Dockerfile for Sample Python Flask Hello World application
#
FROM python:3.5-alpine

MAINTAINER Sanjay Singh Shekhawat <shekhawatsanjay23@gmail.com>

# Create working space
WORKDIR /app/src

# Copy the requirements.txt file in docker image
COPY requirements.txt /app/src/requirements.txt

# Install all the required pip packages
RUN apk add --no-cache --virtual .build-deps openssl-dev\
  build-base gcc python-dev libffi-dev \
    && pip install -r requirements.txt \
    && find /usr/local \
        \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
    )" \
    && apk add --virtual .rundeps $runDeps \
    && apk del .build-deps

# Copy the application code in docker image
COPY app.py /app/src/app.py

EXPOSE 5000

CMD ["python", "app.py"]
