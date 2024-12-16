# Chameleon Docker Registry

This repository helps you set up your own private docker registry on a KVM instance.


## Setup

Pre-requisite: Setup and configure a [KVM instance](https://chameleoncloud.readthedocs.io/en/latest/technical/kvm.html).
Setup security groups to permit 22 (ssh), 80 (http), and 443 (https).

1. Install [docker](https://docs.docker.com/engine/install/) and docker-compose. Install package apache2-utils.

2. Disable firewall (since we are using security groups)

```
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

3. Clone this git repo

```
git clone https://github.com/ChameleonCloud/kvm_private_registry.git
```

4. Create `users.csv`, with information on how users should authenticate. Each line should be `username,password`.

5. Run the command `./run.sh`. You will be asked for your email, which Let's Encrypt requires to request an SSL certificate. Then this command will create the file `htpasswd`, which is used by the registry to authentiate users.

In the output, you'll see a line like:
```
Starting registry on kvm-dyn-W-X-Y-Z.tacc.chameleoncloud.org
```
where W-X-Y-Z refers to the floating IP address of the KVM instance. Take note of this hostname.

6. On your local machine, run `docker login kvm-dyn-W-X-Y-Z.tacc.chameleoncloud.org`, using the hostname from step 5. You'll be asked for a username and password, which must come from `users.csv`. Once successful, you can use this docker registry as normal.

7. If you require further functionality, such as multi-tenant namespaces, see [this repo](https://github.com/cesanta/docker_auth) for how to configure an additional `docker_auth` service.

## Troubleshooting

- Self-signed certificate error: Check the output of the command `docker compose logs traefik` for more details. These logs may describe a problem that occured while requesting a certificate.

- 404 Not Found: This may be an issue with the registry service failing to start. Check the output of `docker compose logs registry`.

- Other error: Check that the registry service is working by running this curl command. If it shows an `UNAUTHORIZED` message, then the services are working as expected (since curl is not supplying credentials).
```
curl -L https://kvm-dyn-W-X-Y-Z.tacc.chameleoncloud.org/v2/_catalog/
```
Try `docker logout kvm-dyn-W-X-Y-Z.tacc.chameleoncloud.org` and then re-login.
