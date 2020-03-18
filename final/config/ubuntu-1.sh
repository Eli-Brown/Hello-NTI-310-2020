#!/bin/bash
gcloud compute instances create ubuntu-1 \
--image-family ubuntu-1804-lts \
--image-project ubuntu-os-cloud \
--zone us-central1-a	 \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/ \
--private-network-ip=10.128.0.10
