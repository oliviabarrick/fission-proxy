`fission-proxy` helps secure your fission controller API by creating kubectl port forwards
to your fission controller API running inside of your cluster, so that you don't need to 
expose the unauthenticated API to the internet.

# Install the fission-controller proxy

To use, first install the fission-controller API proxy into your namespace so that you can
port forward to it without direct access to your fission controller's pod.

Apply the proxy:

```
kubectl apply -f fission-proxy.yml
```

The fission controller proxy should now be running in your current namespace.

# Install the fission cli and wrapper

First, install the fission cli to `fission-cli`:

```
curl -Lo fission-cli https://github.com/fission/fission/releases/download/0.4.1/fission-cli-linux
sudo install -m 755 -T fission-cli /usr/local/bin/fission-cli
```

Now install the fission-cli wrapper:

```
curl -Lo fission.sh https://raw.githubusercontent.com/justinbarrick/fission-proxy/master/fission.sh
sudo install -m 755 -T fission.sh /usr/local/bin/fission
```

# Use fission

You can now use fission normally. It will create proxies into your cluster as necessary, using `kubectl port-forward`:

```
➜  fission env create --name nodejs --image fission/env
Using proxy pod fission-proxy-7f657ffb97-qjh56.
Starting fission proxy since it did not exist already.
fission-proxy started.
Waiting for fission proxy to come up.
environment 'nodejs' created
➜  curl https://raw.githubusercontent.com/fission/fission/master/examples/nodejs/hello.js -O -s
➜  fission function create --name hello --env nodejs --code hello.js
Using existing fission proxy.
function 'hello' created
➜  fission route create --method GET --url /hello --function hello 
Using existing fission proxy.
trigger 'ce770134-efbb-4b82-bbd1-06796b24530f' created
➜   
Hello, world!
➜   
```
