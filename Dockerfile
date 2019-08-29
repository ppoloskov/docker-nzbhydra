FROM alpine:3.10 

ENV PUID="1001"
ENV PGID="1001"

# Nzbhydra repo
ENV GITHUB_REPO "theotherp/nzbhydra2"

WORKDIR /opt/nzbhydra2

RUN apk add --no-cache curl openjdk9-jre-headless unzip && \
	curl -s https://api.github.com/repos/${GITHUB_REPO}/releases/latest \
		| grep -e "releases/.*-linux\.zip" \ 
		| cut -d \" -f 4 \
		| sed -e "s/\(.*\)/url = \"\1\"/" \
		| curl -K - -L -o /tmp/nzbhydra2.zip && \
	unzip -o -j -p /tmp/nzbhydra2.zip '*core*exec.jar' > ./core.jar && \
	rm -rf /tmp/* && \
	addgroup -g ${PGID} notroot && \
	adduser -D -H -G notroot -u ${PUID} notroot && \
	mkdir /config /blackhole && \
 	chown -R notroot:notroot /config /blackhole && \
	apk del curl unzip

EXPOSE 5076

VOLUME [ "/config", "/blackhole" ]
HEALTHCHECK CMD netstat -an | grep 5076 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

USER notroot

ENTRYPOINT [ "java"]
CMD ["-Xmx256M", \
	"-noverify", \
	"-jar", "/opt/nzbhydra2/core.jar", \
	"directstart", \
	"--datafolder", "/config", \
	"--baseurl", "/nzbhydra", \
	"--nobrowser" ]

