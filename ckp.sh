#!/bin/bash

# Function to prompt for input with a default value
prompt() {
  local prompt_text=$1
  local default_value=$2
  read -p "$prompt_text [$default_value]: " input
  echo "${input:-$default_value}"
}

# Prompt user for local registry and Kubernetes version
LOCAL_REGISTRY=$(prompt "Enter the local registry" "internal.yntraa.com")
K8S_VERSION=$(prompt "Enter the Kubernetes version" "1.28.3")

# Define the images and their specific tags
declare -A IMAGES_TAGS=(
  ["docker.io/coredgeio/kube-apiserver"]=v$K8S_VERSION
  ["docker.io/coredgeio/kube-controller-manager"]=v$K8S_VERSION
  ["docker.io/coredgeio/kube-scheduler"]=v$K8S_VERSION
  ["docker.io/coredgeio/kube-proxy"]=v$K8S_VERSION
  ["docker.io/coredgeio/etcd"]="3.5.9-0"
  ["ghcr.io/kube-vip/kube-vip"]="v0.6.2"
  ["docker.io/calico/kube-controllers"]="v3.27.2"
  ["docker.io/calico/cni"]="v3.27.2"
  ["docker.io/calico/node"]="v3.27.2"
  ["docker.io/coredgeio/coredns"]="v1.10.1"
  ["docker.io/coredgeio/csi-attacher"]="v4.4.2"
  ["docker.io/coredgeio/csi-provisioner"]="v3.6.2"
  ["docker.io/coredgeio/csi-snapshotter"]="v6.3.2"
  ["docker.io/coredgeio/csi-resizer"]="v1.9.2"
  ["docker.io/coredgeio/livenessprobe"]="v2.11.0"
  ["docker.io/coredgeio/cinder-csi-plugin"]="v1.30.0"
  ["docker.io/coredgeio/csi-node-driver-registrar"]="v2.9.2"
  ["docker.io/coredgeio/metrics-server"]="v0.7.1"
)


# Pull, tag, and push each image from IMAGES_TAGS
for IMAGE in "${!IMAGES_TAGS[@]}"; do
  TAG=${IMAGES_TAGS[$IMAGE]}
  echo "Processing image: ${IMAGE}:${TAG}"

  # Pull the image from Docker Hub
  docker pull ${IMAGE}:${TAG}

  # Tag the image for the local registry
  LOCAL_IMAGE=$(echo ${IMAGE} | sed "s|docker.io/||;s|ghcr.io/||")
  docker tag ${IMAGE}:${TAG} ${LOCAL_REGISTRY}/${LOCAL_IMAGE}:${TAG}

  # Push the image to the local registry
  docker push ${LOCAL_REGISTRY}/${LOCAL_IMAGE}:${TAG}

  echo "Successfully processed ${IMAGE}:${TAG}"
done

# Pull, tag, and push each additional image
for FULL_IMAGE in "${ADDITIONAL_IMAGES[@]}"; do
  IMAGE=$(echo ${FULL_IMAGE} | cut -d ':' -f 1)
  TAG=$(echo ${FULL_IMAGE} | cut -d ':' -f 2)
  echo "Processing additional image: ${IMAGE}:${TAG}"

  # Pull the image from Docker Hub
  docker pull ${IMAGE}:${TAG}

  # Tag the image for the local registry
  LOCAL_IMAGE=$(echo ${IMAGE} | sed "s|docker.io/||;s|ghcr.io/||")
  docker tag ${IMAGE}:${TAG} ${LOCAL_REGISTRY}/${LOCAL_IMAGE}:${TAG}

  # Push the image to the local registry
  docker push ${LOCAL_REGISTRY}/${LOCAL_IMAGE}:${TAG}

  echo "Successfully processed ${IMAGE}:${TAG}"
done

echo "All images have been pulled, tagged, and pushed to the local registry."
