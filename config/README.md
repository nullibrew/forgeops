# Platform Configurations

This is a work in progress, and is not complete. For the 7.0.0 release, this folder will contain one or more platform samples.

## SETUP - READ THIS FIRST

1. Set the environment variable HELM_PREFIX to a unique value before running skaffold (for example, your initials).

```bash
export HELM_PREFIX=ws
# run skaffold....
skaffold
```

Helm release names are global and the prefix is used to make each release name unique so that multiple deployments do
not collide. This workaround will not be required with Helm 3.

2. Edit or copy an existing helm values file to helm-common.yaml. This common yaml file is used to set the high level deployment parameters (FQDN, etc.).

```bash
cp helm-example.yaml helm-common.yaml
```

`helm-common.yaml` is in .gitignore, and will not be checked in to git.


## Note

There are still issues with AM file based configuration that need to be sorted out.

For now, use we recommend using the individual skaffold.yaml files that are found in each product folder.  The general idea is to
`skaffold run` those components that are stable (i.e. you are not iterating on the configuration) and use
`skaffold dev` on the component you want to develop with.

See am/README.md - there are special considerations for setting up file based config and running AM.

The skaffold-db.yaml is used to deploy the idrepo directory instance. This will be a component that you want to keep around
to avoid reconfiguring the directory each time.  Running `skaffold delete -f skaffold-db.yaml` will delete the deployment but will preserve the PVC - so you can `skaffold run -f skaffold-db.yaml` again to get the directory back up to its previous state.


## Skaffold

[skaffold](https://skaffold-latest.firebaseapp.com/) is used to provide an iterative development workflow, and also for final runtime deployment using continous delivery tools.

There is a top level skaffold.yaml that can be used to iterate on the entire platform:

```bash
cd config
skaffold dev
```

## Outstanding issues

* See the am/README.md
* The fqdn needs to be updated in the embedded AM configuration. Use sed or equivalent for now.
* Amster initial import for smoke test config. Take from forgeops-init
