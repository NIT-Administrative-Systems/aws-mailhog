# Mailpit Instance for AWS Deployment
This is an IaC module that deploys a [Mailpit](https://mailpit.axllent.org/) server to AWS. The web UI will be behind our ALB with SSO, and the mail port will have simple authentication and be open to Northwestern's network.

The deployment is not durable. If you redeploy, there will be a brief outage. Mails kept in memory will be lost. But that is the way of the Mailpit anyways.

You are expected to bring your own VPC, subnets, and ALB. This module will create a listener on the ALB.

An NLB will be created for you to handle the SMTP traffic. Because who has their own ready-to-go NLB, lol?

## Usage
Deploying this is fairly simple. This will bind to your ALB on port `8025` for viewing the web interface.

The SMTP port is 1025, exposed on the NLB's hostname. It is recommended to CNAME that with something friendly.

In your IaC, include:

```hcl
module "mailhog" {
    source                 = "github.com/NIT-Administrative-Systems/aws-mailhog?ref=v2.0.0"
  
    # These values are for SBX and used for examples, but you'd probably want to use the remote state from the shared resources!
    region                 = "us-east-2"
    hostname               = "ado-mailhog.entapp.northwestern.edu"
    vpc_id                 = "vpc-04897d7100b4e9b62"
    ecs_subnet_ids         = ["subnet-002338fccd5226b4d"] # Pvt-AZ1 (it's important to use the PRIVATE subnet!)
    alb_arn                = "arn:aws:elasticloadbalancing:us-east-2:085135368082:loadbalancer/app/as-ado-sbx/10ff301adaf7872d"
    alb_security_group_ids = ["sg-0f9218d020d56b4b1"]
    oidc_secret            = "seekrit" # From Azure AD
}
```

The module will expose the following outputs:

| Output           | Purpose                                                                  |
|------------------|--------------------------------------------------------------------------|
| `log_group_name` | Name of the ECS task's log group. Useful for forwarding logs to DataDog. |
| `nlb_hostname`   | NLB hostname for SMTP traffic.                                           |

## Historical
This once deployed a Mail*hog* service. Mailhog is no longer actively maintained, and Mailpit is a drop-in replacement. 

But if you see Mailhog references: this is why! In hindsight, naming this "mail capture" or something generic like that would have been more future-proof. But you live and learn! 🥂