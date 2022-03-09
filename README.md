# Mailhog Instance for AWS Deployment
This is an IaC module that deploys a [Mailhog](https://github.com/mailhog/MailHog) server to AWS. The web UI will be behind our ALB with SSO, and the mail port will have simple authentication and be open to Northwestern's network.

The deployment is not durable. If you redeploy, there will be a brief outage. Mails kept in memory will be lost. But that is the way of the Mailhog anyways.

You are expected to bring your own VPC, subnets, and ALB. This module will create a listener on the ALB.

## Usage
Deploying this is fairly simple. This will bind to your ALB on port `8025` for viewing the web interface.

The SMTP port is 1025, exposed on the ECS task's IP. That is not static. Unfortunately the only way to make it static is to deploy an NLB, and who has money to waste on that for a mailhog?

In your IaC, include:

```hcl
module "mailhog" {
    source                 = "github.com/NIT-Administrative-Systems/aws-mailhog?ref=v1.0.0"
  
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
