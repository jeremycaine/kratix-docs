#!/bin/sh

set -eux

# Get the user's input
image=$(yq '.spec.image' /kratix/input/object.yaml)
service_port=$(yq '.spec.service.port' /kratix/input/object.yaml)

# Get the request name and namespace
name=$(yq '.metadata.name' /kratix/input/object.yaml)
namespace=$(yq '.metadata.namespace' /kratix/input/object.yaml)

# Create a deployment
kubectl create deployment ${name} \
    --namespace=${namespace} \
    --replicas=1 \
    --image=${image} \
    --dry-run=client \
    --output yaml > /kratix/output/deployment.yaml

# Create a service
kubectl create service nodeport ${name} \
    --namespace=${namespace} \
    --tcp=${service_port}\
    --dry-run=client \
    --output yaml > /kratix/output/service.yaml

# Create an ingress
kubectl create ingress ${name} \
    --namespace=${namespace} \
    --class="nginx" \
    --rule="${name}.local.gd/*=${name}:${service_port}" \
    --dry-run=client \
    --output yaml > /kratix/output/ingress.yaml
