# Platform Configurations

This is a work in progress, and is not complete. For the 7.0.0 release, this folder will contain one or more platform samples.

## Note

The all in one skaffold.yaml is not ready for general usage. There are still too many issues with AM file based configuration that need to be sorted out.

For now, use the individual skaffold.yaml files that are found in each product folder.  The general idea is to 
`skaffold run` those components that are stable (i.e. you are not iterating on the configuration) and use
`skaffold dev` on the component you want to develop with.

See the am/README.md - there are special considerations for setting up file based config and running AM.

The skaffold-db.yaml is used to deploy the idrepo directory instance. This will be a component that you want to keep around 
to avoid reconfiguring the directory each time.  Running `skaffold delete -f skaffold-db.yaml` on it will delete the deployment but will preserve the PVC - so you
can `skaffold run -f skaffold-db.yaml` again to get the directory back up.


## Skaffold 

[skaffold](https://skaffold-latest.firebaseapp.com/) is used to provide an iterative development workflow, and also for final runtime deployment using continous delivery tools.

There is a top level skaffold.yaml that can be used to iterate on the entire platform:

```bash
cd config
skaffold dev
```

# Outstanding issues to be worked on:

*  See the am/README.md
