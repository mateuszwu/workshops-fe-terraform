1. Make sure that you have `asdf` installed
2. Run `asdf plugin add terraform`
3. Run `asdf plugin add awscli`
4. Run `asdf install`
5. Go to https://selleo.awsapps.com/start
6. Run `aws configure sso`
Pick the workshops app

SSO start URL: https://selleo.awsapps.com/start
SSO Region: eu-west-1
CLI default client Region: eu-central-1
CLI default output format json
If it asks for profile name, set it to: selleo-workshops

7. Run `export AWS_PROFILE=selleo-workshops`
8. Run `terraform init`
9. Run `terraform plan` and verify that everything works

