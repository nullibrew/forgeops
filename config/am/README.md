# Notes

File Based Config (FBC) requires the config store to be present (this will be fixed for 7.x).

We are using the "idrepo" instance as the all in one DS instance for the userstore, configstore, and CTS. AM will need
a policy store - so it makes sense to consolidate this around the idrepo instance. For production deployments
a separate ctsstore will also be configured.

## Dev Mode

The AM container can run in "dev" mode or normal mode. In Dev mode,  `minikube mount` is used to mount the openam/
folder on the containers /home/forgerock/openam.  This allows AM to write back configuration changes to the
local folder. These are later committed to git for promotion to a QA instance using CI/CD.

In normal mode, the docker build copies in the contents of the folder (COPY) so that the configuration files are part of the image (to simplify things we copy in the configuration in all cases, but in dev mode the folder gets overlayed with the local mount). When the images
are deployed with CI/CD, `skaffold run` is used to tag the images with a git hash, and to deploy them to a running namespace.

The `devMode: true` flag must be set in the helm chart to enable the hostPath mount in the AM container. This can be set in the `skaffold.yaml` file.

By default, devMode is set to false. This provides a better out of box experience for running on GKE (where the host path mounts do not work).

As an alternative to mounting the local folder, `kubectl cp` can be used to copy files from a running AM pod. We would like feedback
on the use of kubectl vs. host mounting.  The advantage of using kubectl is a simplifed helm charts and common experience across minikube and GKE.

Example of kubectl cp:

``` bash
# Find the am pod
kubectl get pod
kubectl cp sk-am-pod1234:/home/forgerock/openam/am/config  ./tmp
```


## Preparing the idrepo

You must prepare the idrepo instance with an amster install. You can not do this currently using file based configuration - the
AM installer must run. Once you have your idrepo prepared, you are advised to retain the PVC between development sessions
so that you do not have to repeat this procedure.

Steps:

### Create a new idrepo instance

[This is kludgy... hoping for a better procedure soon...]

```bash
cd forgeops/config
skaffold run -f skaffold-db.yaml
```

### Create a temporate AM home directory mount

In a new shell window, run the mount command for minikube, and use an *empty* folder for the AM home.
The folder needs to be empty otherwise AM will attempt to use the configuration - but will fail to boot
because the idrepo is not prepared.


```bash
cd am/
mkdir tmp
minikube mount ./tmp:/openam
```

Note: The /openam path is a host mount on the minikube VM. The helm chart maps this to /home/forgerock/openam in the AM pod. This
mapping occurs only if `devMode: true` is set on the helm chart - which the skaffold.yaml file sets.

This command needs to be left running.

### Start AM and amster

```bash
cd amster/
skaffold run

cd am/
skaffold dev
```

Wait until amster has installed AM. Use `stern amster` or `kubectl logs amster-xxx -f`. For some reason
this takes a very long time (could be due to minikube host mounts being slow...)

You can now either copy the new files from tmp/ to openam/, and use those as your new file based configuration,
or restart AM, and using the existing files. At this time, upgrades between snapshots are not supported, and you
will need to reinstall each time.

### Running AM against an existing idrepo and openam/ folder

Now that the idrepo has been initialized, and you have a basic file based configuration under openam/

First mount the local openam folder on minikube:

```bash
# kill the existing minikube mount command..
minikube mount ./openam:/openam
```


Next, use `skaffold run` to deploy AM. If you use `skaffold dev` you will
see an endless loop of AM writing changes to openam/, and skaffold triggering a redeploy.
Using `run` will avoid the loop:

```bash
skaffold run
# When you are finished, delete the deployment using:
skaffold delete
```



## Deleting the idrepo instance

```bash
cd forgeops/config
skaffold delete -f skaffold.db
# If you want to blow away the PVC to start fresh:
kubectl delete pvc db-idrepo-0
```

### Updating the deployment FQDN in FBC

Eventually this will be supported via commons expressions. For now, your choices are:

* Using your ide, search and replace the FQDN. The site is openam/config/services/realm/root/iplanetamplatformservice/1.0/globalconfig/default/com-sun-identity-sites/site1/accesspoint.json
* Using a sed command, do the same as above.

Sample sed script (executed in the container, before AM starts)
```bash
find /home/forgerock/openam/config -type f -print0 | xargs -0 sed -i -e s/default\.iam\.example\.com/test.iam.example.com/g
```

Sed script, executed locally (Note: for Mac, we use gsed as Mac sed behaves differently)
```
find openam/config  -type f -exec gsed -i -e 's/default\.iam\.example\.com/test.iam.forgeops.com/g' {} \;
# Search for string you just changed
find openam/config  -type f -print0 | xargs -0 grep test.iam.forgeops.com
```

Deleting tmp files;

find openam -name \*-e -type f -exec rm {} \;