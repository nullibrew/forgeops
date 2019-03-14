# frconfig - Manage configuration for the ForgeRock platform components

This chart creates Kubernetes config maps and secrets that are needed by all components of the ForgeRock platform. For example, 
defining the fully qualified domain name (FQDN) of the deployment.

This is a prerequisite chart that must be deployed before other charts such as am, ig, amster, and idm.


## Certificates

cert-manager is used to provision a wildcard SSL certificate of the form `wildcard.$namespace.$domain`.  The default in values.yaml
configures cert-manager to issue self signed certificates (the CA issuer). You can  configure cert-manager to issue certificates
using  Let's Encrypt. Please refer to the [cert-manager](https://github.com/jetstack/cert-manager) project.
