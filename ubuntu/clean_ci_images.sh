#!/bin/bash

# List prefix
list_prefix="
asia.gcr.io
"

for prefix in $list_prefix; do
    # List image
    image_names=`docker images | grep $prefix | awk '{print $1}' | sort | uniq`

    for image_name in $image_names; do
        # Delete old development images
        docker images ${image_name} | egrep -e " b[0-9]+ " | tail -n +3 | awk '{print $3}' | xargs -r docker rmi -f

        # Delete old production images
        docker images ${image_name} | egrep -e " r[0-9]+ " | tail -n +3 | awk '{print $3}' | xargs -r docker rmi -f
    done

    docker images | awk '/<none>/ {print $3}' | xargs -r docker rmi -f
done