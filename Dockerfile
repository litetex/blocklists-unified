FROM alpine:3

RUN apk add --no-cache bash curl python3 py3-pip dos2unix

RUN pip3 install --break-system-packages aggregate6

# Copy scripts
RUN mkdir /scripts
WORKDIR /scripts

ADD scripts/ /scripts/
# Make all sh files executable
RUN find . -type f -name '*.sh' | xargs chmod +x

WORKDIR "/workdir"

ENTRYPOINT [ "/scripts/init.sh" ]
