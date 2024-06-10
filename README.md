# Eficode - Recruitment Task

The original task description can be found in [TASK.md](TASK.md).


## What has been done
In this section, I will describe what has been done in this repository. If there was something I spotted that could be done, but I didn't have time to do it, I will mention it in the "Further possible improvements" section.

> I tracked my work using Linear, in which I've created issues/tickets. If you want to see how I describe things to do, take a look at the expandable commend from the bot that liked each issue in PRs.

Definitions:
- gcp - Google Cloud Platform
- gce - Google Compute Engine

### App Code
- (app) Added `.env` file to centralize environment variables,
- (app) Extracted all variables from the frontend and backend to `.env` file,
- (frontend) Replaced webpack with Vite, removed unnecessary dependencies, and improved HMR,
- (frontend) Added build script to output static assets,

Further possible improvements:
- (backend) tighten CORS policy to allow only specific origins,
- (app) Add corepack to install project dependencies with always-correct version package manager.


### Docker
- (backend) Added Dockerfile.
- (frontend) Added Dockerfile for both environments:
  - dev uses `npm start` to guarantee hot reload,
  - prod uses multi-stage build to build the app and then serve static files with Caddy,
- (compose) Added `docker-compose.yml` to run the app in connected containers.
- (compose) Added `compose watch` script to run the app in development mode.
- (compose, gcp) Added container registry in GCP for storing built containers (to avoid building on VM)

Further possible improvements:
- (CI) Add CI pipeline to build docker images and lint the app,
- (compose) Use [compose secrets](https://docs.docker.com/compose/use-secrets/) to store sensitive data such as OpenWeatherMap API key,
- (compose) Rethink and test if `.prod` and `.build` cannot be used as one production-only docker file (read more on `pull_policy` too)
- (prod-frontend) Parametrize backend port for reverse proxy in Caddyfile,


### Cloud hosting & Terraform
- (terraform, gce) Provision a new e2-micro VM with public keys added:
  - `id_rsa_internship` - for `root` user,
  - `id_rsa_gcp` - for my own `user`.
- (terraform, gcp) Create a VPC with firewall rules:
  - allow port 22 (SSH),
  - allow port 80, 443 (HTTP & HTTPS).
- (terraform, gpc) Add a service account with IAM role to be used for Ansible dynamic inventory,
- (terraform, gcp) Save service account private key and save it to file,
- (terraform) Parametrize Terraform with tfvars.
- (terraform) Create Docker artifact registry,

Further possible improvements:
- (terraform) Use [remote-exec provisioner](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec) to install Docker on the VM (seems interesting, might be bad practice though),
- (terraform, ansible) Use Ansible Vault to store service account key,
- (terraform, gcp) Use [storage bucket](https://cloud.google.com/docs/terraform/resource-management/store-state) to centralize Terraform state - useful for working in a team,
- (terraform, gce) Assign static IP, add DNS record and automate issuing SSL with Let's Encrypt Certbot,
- (terraform, gce) Tighten ranges of allowed IPs for connecting with SSH,
- (gcp) Find a role in IAM for a service account, that has fewer permissions than `roles/viewer`,
- (terraform) Parametrize service account key location,
- (terraform) Organize a project in a (possibly) better way - break `main.tf` into smaller, more focused parts,
- (terraform) Kickstart a new GCP project with [project-factory](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest) (would have to revise what it adds besides just the project though)


### Ansible
- (inventory) Added dynamic inventory based on VMs present in GCE (works with ephemeral IPs, should work with static IPs too),
- (playbook) Provision docker,
- (playbook) Deploy app through `docker-compose.prod.yaml`,

Further possible improvements:
- (ansible) Use vault to store secrets, such as private keys, or .env files with API keys

---


## How to run
Before starting, you need to:
- get yourself an API key in the OpenWeatherMap ["Current Weather Data" API](https://openweathermap.org/price).

Afterwards:
1. Clone the repository.
2. Rename `.env.example` to `.env` and fill in the `OPENWEATHERMAP_API_KEY` variable with your OpenWeatherMap API key,
3. Change other variables if needed (such as target city),
4. Run `docker-compose watch` to build and start the containers in the background,
5. Open `http://localhost:8000` in your browser to see the app running.

All the commands:
```bash
git clone git@github.com:eficode-recruitment/eficode-recruitment-2024.git
cd eficode-recruitment-2024
cp .env.example .env
# Fill in the .env file, and then run:
docker-compose watch
```

> If you modified the .env file while containers were running, you need to restart the containers by running `docker-compose watch` again.

---

## How to deploy
High-level overview of the process:
1. Setup software and environment,
2. Provision infrastructure with Terraform,
3. Build and push app Docker images to GCP Artifact Registry,
4. Run deployment with Ansible,
5. See the app live.

### Software setup
Required software to run the deployment process:
- [full Ansible package](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html),
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli),
- [gcloud CLI](https://cloud.google.com/sdk/docs/install).

> This manual will assume that Ansible was installed with `pipx`.

`google.cloud.gcp_compute` requires two additional dependencies: `requests google-auth`.
If you installed Ansible with pipx, you can inject them into your Ansible installation:
```bash
pipx inject ansible requests google-auth
```

### Environment setup
Before beginning the deployment process, you need to:
- [OpenWeatherMap API key](https://openweathermap.org/price) (can be the same as the one used during development),
- [Create a GCP project](https://console.cloud.google.com/projectselector2/home/dashboard) and copy Project ID,
- Enable the following APIs for your [GCP project](https://console.cloud.google.com/projectselector2/home/dashboard):
  - [Compute Engine API](https://console.cloud.google.com/flows/enableapi?apiid=compute.googleapis.com),
  - [Artifact Registry API](https://console.cloud.google.com/flows/enableapi?apiid=artifactregistry.googleapis.com).

After the above is done, authenticate yourself with gcloud CLI:
```bash
gcloud auth application-default login
```
After authenticating a file location of your credentials will be shown in the console.

If you are building the Docker images locally, you also need to authenticate with GCP Artifact Registry:
```bash
gcloud auth configure-docker europe-central2-docker.pkg.dev
```
> Note: The region `europe-central2` is the default region in example configs. If you use a different region, replace it in the command above.

Next, copy variable files:
```bash
cp terraform.example.tfvars terraform.tfvars
cp .env.example .env
```
and fill-in/replace:
- `terraform.tfvars`
  - replace `GCP_PROJECT_ID` your GCP Project ID (found in the [project dashboard](https://console.cloud.google.com/projectselector2/home/dashboard))
  - path to credentials file (`gcp_credentials_file`), if it's location doesn't match the one in config,
- `.env`:
  - paste your `OPENWEATHER_API_KEY` as-is,
- `/ansible/inventory/gcp.yaml`:
  - replace `gcp_project_id` with your GCP Project ID. 

Next, configure the SSH private key location (used by Ansible and Terraform).
By default, configs assume that the key is at `~/.ssh/id_rsa_internship`.
If the key is named differently or is located somewhere else - modify the configs:
- `ansible/ansible.cfg` - `private_key_file` variable,
- `terraform.tfvars` - `gce_ssh_pub_key_eficode` variable.


### Provision infrastructure with Terraform
We use Terraform to provision infrastructure. It will set up:
- a single VM to run the app,
- a Virtual Private Cloud network (VPC),
- a firewall rules to allow SSH (port 22), and HTTP/HTTPS (ports 80, 443),
- an Artifact Registry for Docker images,
- a service account with a viewer role, and save its key.

To provision all above, use:
```bash
terraform init
terraform apply
```

A note about provisioned users:
- `root` user on the VM has the `id_rsa_internship` key added,
- `user` has the `id_rsa_gcp` key added.

> If you need to generate your own key-pair, you can use `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_gcp`. Make sure to change paths appropriately in the configs afterward.

### Build Docker images
To avoid running a build process on the VM, we will build the images locally and push them to GCP Artifact Registry.
To do so, run:
```bash
docker-compose -f docker-compose.prod.yaml build
docker-compose -f docker-compose.prod.yaml push
```
This will push the images to the Artifact Registry, where they will be pulled by the VM during deployment.


### Run deployment with Ansible
To deploy the app, run:
```bash
cd ansible
ansible-playbook tasks/deploy.yaml
```
> Beware! There's a chance that the VM's fingerprint will change for known IP.
> If you encounter an error, remove the IP from the `~/.ssh/known_hosts` file.
> You can use `ssh-keygen -R <IP> -f "~/.ssh/known_hosts"` to remove the entry.
> After that, try running the deployment playbook again.

By default, the playbook will also install Docker on the VM. If you want to skip this step, run:
```bash
ansible-playbook tasks/deploy.yaml -e "install_docker=false"
```

## See the app live
After the deployment process is finished, you can access the app by visiting the VM's IP address in your browser.
The IP address can be found in the Terraform output or in the GCP console.
