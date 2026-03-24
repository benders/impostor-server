#!/bin/bash

VOLUMES="impostor-server_caddy_data"

mkdir -p backups

for volume in $VOLUMES; do
    filename="${volume}-$(date +%Y-%m-%d).tar.gz"
    echo "${volume} -> ${filename}"

    (cd backups && docker run \
        --rm \
        -v ${volume}:/data \
        -v "$(pwd)":/backup \
        alpine \
        tar -czvf "/backup/${filename}" -C /data ./ \
    )
    
    echo
done
