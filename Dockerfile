FROM python:2.7.16

# Install updates and dependencies
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y -q \
    bzip2 \
    xz-utils \
    curl \
    zip \
    unzip \
    build-essential \
    git \
    ca-certificates \
    libkrb5-dev \
    imagemagick \
    netbase && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY requirements_dev.txt /tmp/requirements_dev.txt

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

RUN curl -sSJL "https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip" -o /tmp/google-cloud-sdk.zip \
    && unzip -q /tmp/google-cloud-sdk.zip -d /usr/local \
    && rm -f /tmp/google-cloud-sdk.zip \
    && /usr/local/google-cloud-sdk/install.sh \
        --usage-reporting=true \
        --path-update=true \
        --bash-completion=true \
        --rc-path=/root/.bashrc \
        --additional-components app-engine-python app-engine-java beta

RUN pip install -r /tmp/requirements_dev.txt -U

ENV PATH /usr/local/google-cloud-sdk/bin:$PATH
ENV TERM=xterm-256color

ARG NODE_VERSION=8.16.0
ARG NPM_VERSION=6.9.0
ARG CHROMEDRIVER_VERSION=2.44
ARG SONAR_SCANNER_VERSION=3.3.0.1492

RUN curl -sSJL "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" -o /tmp/node-v$NODE_VERSION-linux-x64.tar.gz \
    && tar -xzf "/tmp/node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && npm install --silent -g npm@"$NPM_VERSION"  \
    && rm -f "/tmp/node-v$NODE_VERSION-linux-x64.tar.gz"

RUN curl -sSJL "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" -o /tmp/chromedriver_linux64.zip \
    && unzip -q /tmp/chromedriver_linux64.zip -d /tmp \
    && chmod +x /tmp/chromedriver \
    && mv -f /tmp/chromedriver /usr/local/share/chromedriver \
    && ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver \
    && rm -f /tmp/chromedriver_linux64.zip

RUN curl -sSJL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip" -o /tmp/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip \
    && unzip -q "/tmp/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip" -d /tmp \
    && chmod +x /tmp/sonar-scanner-$SONAR_SCANNER_VERSION-linux \
    && mv -f /tmp/sonar-scanner-$SONAR_SCANNER_VERSION-linux /usr/local \
    && ln -s /usr/local/sonar-scanner-$SONAR_SCANNER_VERSION-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

RUN pip install pip --upgrade