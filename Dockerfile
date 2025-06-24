
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    openjdk-11-jdk \
    zlib1g-dev \
    libncurses5 \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    liblzma-dev \
    libbz2-dev \
    build-essential \
    git \
    gnupg \
    lsb-release \
    gcc \
    g++ \
    make \
    libtool \
    pkg-config \
    autoconf \
    automake \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install SRA Toolkit
RUN wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz && \
    tar -xvzf sratoolkit.current-ubuntu64.tar.gz && \
    mv sratoolkit.* /opt/sratoolkit && \
    ln -s /opt/sratoolkit/bin/* /usr/local/bin/

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update -y && apt-get install -y google-cloud-sdk

CMD ["/bin/bash"]
