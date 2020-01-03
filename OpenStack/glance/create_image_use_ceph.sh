#!/usr/bin/env bash

set -xe

export IMAGE_ID=$(uuidgen)
export CLUSTER_ID=$(ceph fsid)
export POOL="glance.images"
export RAW_FILE="ubuntu18.04.raw"

glance image-create \
        --id ${IMAGE_ID} \
        --disk-format raw \
        --container-format bare \
        --file /dev/null

rbd -p glance.images snap unprotect ${IMAGE_ID}@snap
rbd -p glance.images snap rm ${IMAGE_ID}@snap
rbd -p glance.images rm ${IMAGE_ID}

# use qemu-img upload image, it can use qcow2 format, but slower.
#qemu-img convert -f qcow2 -O raw \
#       ${QCOW2_FILE} \
#       rbd:${POOL}/${IMAGE_ID}
rbd import ${RAW_FILE} ${IMAGE_ID} \
        --dest-pool ${POOL} --image-format 2
rbd info ${POOL}/${IMAGE_ID}

rbd snap create ${POOL}/${IMAGE_ID}@snap
rbd snap protect ${POOL}/${IMAGE_ID}@snap
