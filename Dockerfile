# syntax=docker/dockerfile:1

# Pull CLIProxyAPI Image from docker hub
FROM eceasy/cli-proxy-api:latest

# Install FUSE and dependencies
RUN apk add --no-cache ca-certificates fuse curl bash

# Install tigrisfs
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi && \
    if [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    VERSION=$(curl -s https://api.github.com/repos/tigrisdata/tigrisfs/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4) && \
    curl -L "https://github.com/tigrisdata/tigrisfs/releases/download/${VERSION}/tigrisfs_${VERSION#v}_linux_${ARCH}.tar.gz" -o /tmp/tigrisfs.tar.gz && \
    tar -xzf /tmp/tigrisfs.tar.gz -C /usr/local/bin/ && \
    rm /tmp/tigrisfs.tar.gz && \
    chmod +x /usr/local/bin/tigrisfs

# Set working directory 
WORKDIR /CLIProxyAPI/

# Copy Configuration
COPY container_src/config.yaml .
COPY container_src/startup.sh /startup.sh

RUN chmod +x /startup.sh

# Set timezone environment
ENV TZ=Asia/Shanghai

# Expose CLIProxyAPI default port 8317
EXPOSE 8317

ENTRYPOINT ["/startup.sh"]

CMD [ "./CLIProxyAPI" ]
