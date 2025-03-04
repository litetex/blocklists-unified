FROM alpine:3

RUN apk add --no-cache bash curl python3 py3-pip python3-dev dos2unix \
    && apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing py3-py-radix

RUN pip3 install --break-system-packages aggregate6

# Copy scripts
RUN mkdir /scripts
WORKDIR /scripts

ADD scripts/ /scripts/
# Make all sh files executable
RUN find . -type f -name '*.sh' | xargs chmod +x

WORKDIR "/workdir"

ENTRYPOINT [ "/scripts/init.sh" ]
