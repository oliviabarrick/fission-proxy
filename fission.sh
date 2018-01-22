#!/bin/bash
FISSION_PORT=8000

function kubectl {
    docker run -v $KUBECONFIG:/root/.kube/config:ro $DOCKER_ARGS lachlanevenson/k8s-kubectl:v1.9.2 "$@"
}

function get_proxy {
    kubectl get pods -o json --selector name=fission-proxy -o jsonpath='{ .items[0].metadata.name }'
}

function wait_for_proxy {
    while ! timeout 1 fission-cli --server http://127.0.0.1:$FISSION_PORT function list 2&>1 > /dev/null; do
        >&2 echo "Waiting for fission proxy to come up."
    done
}

function port_forward { 
    if [ "$(docker ps --filter name=fission-proxy -q)" == "" ]; then
        proxy_pod=$(get_proxy)

        >&2 echo "Using proxy pod $proxy_pod."
        >&2 echo "Starting fission proxy since it did not exist already."

        docker rm fission-proxy > /dev/null
        DOCKER_ARGS="--name fission-proxy -d --net=host" kubectl port-forward $proxy_pod $FISSION_PORT:80 > /dev/null

        >&2 echo "fission-proxy started."
    else
        >&2 echo "Using existing fission proxy."
    fi

    wait_for_proxy
}

if [ "$1" == "stop" ]; then
    echo Stopping fission-proxy
    docker stop fission-proxy > /dev/null
    exit
fi

port_forward

fission-cli --server http://127.0.0.1:$FISSION_PORT $@
