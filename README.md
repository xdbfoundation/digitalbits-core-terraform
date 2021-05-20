For successfull apply in the file `terraform.tfvars` specify following variables:

`domain_name` - domain name for network nodes, for example 
    
        domain_name = "livenet.mycompany.com" 

Hosted zone in AWS Route53 will be created with this name and ACM certificate for this domain. During `terraform apply` DNS validation will be initiated and you will have in total 45 minutes to update NS records in your current domain registar and changes to be propageted and ACM certificates to be validated by AWS.

`DD_API_KEY` (optional) - DataDog api key, for example 

        DD_API_KEY  = "20725dc8be182ec76c8e76eb8f2e896f"

If you want blockchain node metrics to be exported to [DataDog](https://datadoghq.com), please, specify your API key and uncomment in file `region/compute/user_data.tpl` following lines 

    #DD_AGENT_MAJOR_VERSION=7 DD_API_KEY ...
    #sudo systemctl enable --now digitalbits-core-prometheus-exporter
    #sudo systemctl enable --now datadog-agent

Otherwise, leave unchanged.

For each node generate public/private keypair either using command `digitalbits-core gen-seed` or pressing button `Generate keypair` on site https://developer.digitalbits.io/lab/#account-creator?network=public

Add secret key as a variable to `terraform.tfvars`. For example 

    secret_deu  = "SBSNWFR6S2TGETGHMXKMNNAX3TA42DPUGFM2SIG4BJWJPV4KZSOINNBK"

Add variable name to the end of `variables.tf` file, for example

    variable "secret_deu" {}

Add new item to the `keys` map in `locals.tf` file. Here you put public key and reference you secret key variable and specify display_name for your node. Also specify directory name is s3 bucket to be created for the node in `history`, `history_get` and `history_put` variables, after `/livenet/` part. For example

    history = "https://${local.history_zone_record}/livenet/deu/"

In file `locals.tf` change variable `org_name` to the name of your organization. For example 
    
    org_name = "MyCompany"

For each region add an alias in `providers.tf` file. For example, for `eu-central-1` AWS region 

    provider "aws" {
        region = "eu-central-1"
        alias  = "eu-central-1"
    }

For each region create separate entry in `main.tf` and provide ISO code for that region and aws provider regional alias. For example, eu-central-1 (Frankfurt) 

    iso = "deu"

    providers = {
        aws = aws.eu-central-1
    }