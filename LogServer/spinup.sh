#!bash.sh

gcloud compute instances create rsyslog-server2 \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-central1-a \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
--metadata-from-file startup-script=/Hello-NTI-310-2020/LogServer/spinup.sh \
--private-network-ip=10.128.0.2
