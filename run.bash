#!/bin/bash
[ "" = "${SSH_AGENT_PID}" ] && {
	echo "Starting SSH agent in daemon mode"
       	ssh-agent -s
} || {
	echo "Good SSH agent running as pid ${SSH_AGENT_PID}"
}

docker inspect "iopsys-build:latest" >/dev/null 2>&1 || {
	[ -f ./iopsys-build.tar ] && {
		echo "Importing image from iopsys-build.tar"
		docker import ./iopsys-build.tar iopsys-build:latest
	} || {
		echo "Building image file iopsys-build:latest from Dockerfile"
		docker build . -t iopsys-build:latest
	}
}

[ "${1}" = "export" ] && {
	echo "Export of image requested"
	docker save --output="./iopsys-build.tar" iopsys-build:latest
	echo "Run script again to start container"

	exit 0
}

docker run --rm \
	--user `id -u` \
	-v $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent \
	-v ~/.ccache:/home/build/.ccache \
	-v $(pwd)/iopsys:/home/build/iopsys:delegated \
	-it iopsys-build:latest \
	/bin/bash 
