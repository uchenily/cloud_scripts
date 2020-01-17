#!/usr/bin/env bash

set -xe

export IMAGE_ID=$(uuidgen)
export CLUSTER_ID=$(ceph fsid)
export POOL="glance.images"

# 根据实际情况修改
export RAW_FILE="cirros-0.4.0-disk.raw"
export IMAGE_NAME="just4test"

# use qemu-img upload image, it uses qcow2 format directly, but slower.
#qemu-img convert -f qcow2 -O raw \
#       ${QCOW2_FILE} \
#       rbd:${POOL}/${IMAGE_ID}
rbd import ${RAW_FILE} ${IMAGE_ID} \
        --dest-pool ${POOL} --image-format 2
rbd info ${POOL}/${IMAGE_ID}

rbd snap create ${POOL}/${IMAGE_ID}@snap
rbd snap protect ${POOL}/${IMAGE_ID}@snap


glance image-create \
        --id ${IMAGE_ID} \
        --disk-format raw \
        --container-format bare \
        --visibility public \
        --name ${IMAGE_NAME}

glance location-add ${IMAGE_ID} \
        --url rbd://${CLUSTER_ID}/${POOL}/${IMAGE_ID}/snap
