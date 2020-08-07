# blender-netrender-cluster

Headless Blender NetRender instance that works as either a master or a slave node in a render farm


## Building

```
git clone https://github.com/GrimKriegor/blender-netrender-cluster.git
cd blender-netrender-cluster/
docker build -t grimkriegor/blender-netrender .
```


## Configuration

Most configuration can be done through environment variables

`RENDER_MODE` can be either `MASTER`, `SLAVE` or unset which defaults to `SLAVE`

`MASTER_IP` defines the master endpoint to which the slave will connect


## Deployment


### Docker

#### Master

```
docker run -e RENDER_MODE=MASTER -p 8000:8000 -it --rm grimkriegor/blender-netrender:2.79
```

#### Slave

```
docker run -e MASTER_IP="render.domain.net" -it --rm grimkriegor/blender-netrender:2.79
```


### Swarm

#### Master

```
version: '3'
services:
  blender:
    image: grimkriegor/blender-netrender:2.79
    environment:
      - RENDER_MODE=MASTER
    ports:
     - '8000:8000'
```

#### Slave

```
version: '3'
services:
  blender:
    image: grimkriegor/blender-netrender:2.79
    environment:
      - MASTER_IP="render.domain.net"
    ports:
     - '8000:8000'
```


### Kubernetes

#### Master

```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: blender
  namespace: render-farm
spec:
  replicas: 1
  selector:
    matchLabels:
      service: blender
  template:
    metadata:
      labels:
        service: blender
    spec:
      containers:
      - name: server
        image: grimkriegor/blender-netrender:2.79
        env:
        - name: RENDER_MODE
          value: "MASTER"
        ports:
        - name: "main"
          containerPort: 8000
---
kind: Service
apiVersion: v1
metadata:
  name: blender
  namespace: render-farm
spec:
  selector:
    service: blender
  type: NodePort
  ports:
  - protocol: TCP
    port: 8000
    targetPort: 8000
    nodePort: 8000
    name: main
```

#### Slave

```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: blender
  namespace: render-farm
spec:
  replicas: 1
  selector:
    matchLabels:
      service: blender
  template:
    metadata:
      labels:
        service: blender
    spec:
      containers:
      - name: server
        image: grimkriegor/blender-netrender:2.79
        env:
        - name: MASTER_IP
          value: "render.domain.net"
```

## Attribuition

Based on [blender-cluster](https://gitlab.com/nicolalandro/blender-cluster) by [Nicola Landro](https://gitlab.com/nicolalandro)

