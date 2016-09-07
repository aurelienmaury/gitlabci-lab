# My gitlab-ci laboratory

* Set env vars with you AWS credentials
* Fill the file `gitlab_farm.var.yml` at your taste
* Run `./deploy.sh`, that will:
    * Create a dedicated VPC and its public and private subnets
    * Spawn a server with an EIP in public subnet
    * Spawn a server in private subnet
    * Manage security groups so that they can collaborate
    * Generate `ssh.cfg` and host inventory so that ansible can connect
* Run `ansible-playbook ansible/install-gitlab.yml` to provision an https gitlab with self-signed cert
* Go to your new gitlab to:
    * Set root user password
    * Create a user for your gitlab runner
    * Retrieve gitlab runner registration token
* Fill a new file `gitlab-runner.vars.yml` to store these values:

```
---
gitlab_runner_tags:
  - "what_ever_you_want"
gitlab_runner_user: "..."
gitlab_runner_pass: "..."
gitlab_runner_register_token: "..."
```

* Run `ansible-playbook ansible/install-gitlab-runner.yml -e@gitlab-runner.vars.yml` to provision the gitlab runner

## Aaaand... CUT!

* Run `./undeploy.sh` if you want to destroy all resources
