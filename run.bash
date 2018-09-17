#!/bin/bash
[ "" = "${SSH_AGENT_PID}" ] && {
	echo "Starting SSH agent in daemon mode"
       	ssh-agent -s
} || {
	echo "Good SSH agent running as pid ${SSH_AGENT_PID}"
}

echo "Adding default key to ssh-agent"
ssh-add

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

image_exists=0
image_running=0
docker ps -a -f name=docker-iopsys | grep -q iopsys && image_exists=1
docker ps -f name=docker-iopsys | grep -q iopsys && image_running=1

[[ ${image_running} -eq 1 ]] && {
	echo "Connect to image"
	docker exec -it docker-iopsys /bin/bash
	exit 0
}

[[ ${image_exists} -eq 1 ]] && {
	echo "Start and connect to image"
	docker start docker-iopsys
	docker exec -it docker-iopsys /bin/bash
	exit 0
}

docker run --name docker-iopsys \
	--user `id -u` \
	-v $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent \
	-v ~/.ccache:/home/build/.ccache \
	-v $(pwd)/external:/home/build/external \
	-v $(pwd)/iopsys:/home/build/iopsys:delegated \
	-it iopsys-build:latest \
	/bin/bash 
