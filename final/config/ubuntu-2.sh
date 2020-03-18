gcloud compute instances create ubuntu-2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-east1-b \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/path/to/script.sh \
--private-network-ip=10.128.0.11
