# Deploy OpenBankProject on Openshift


## Local development environment

Tools required:

- `crc` ([Download & install crc](https://github.com/code-ready/crc/releases))


Start `crc`

```
crc setup
crc start
```

Enable podman:

> This sets-up podman to 'speak' to your local openshift cluster *rather* than your host machine.

```
eval $(crc podman-env)
```


> **Warning**
> If you see "error did not resolve to an alias and no unqualified-search registries are defined"
> Then edit `/etc/containers/registries.conf` and add/uncomment to your prefered registry e.g. `'unqualified-search-registries = ["docker.io"]` [ref: podman no longer searched dockerhub error](https://unix.stackexchange.com/questions/701784/podman-no-longer-searches-dockerhub-error-short-name-did-not-resolve-to-an))


### Clone OBP-API & build `obp-api` image


> **Warning**
> Work in progress. This clone url is subject to change to the [official repo](https://github.com/OpenBankProject/OBP-API.git)

```
git clone https://github.com/KarmaComputing/OBP-API.git
cd OBP-API
```