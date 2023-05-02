# Create all resources with Terraform 
### Manual Steps
1. Add your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to github actions from Settings -> secrets and variables -> actions. Also, run AWS configure and add your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY locally. These values can be changed in the ~/.aws/credentials file as well.
2. In secrets manager on AWS, make a secret called db_credentials and input the following key/value pairs. 
   ```
   DB_NAME = devopsDB
   username = <your desired db username>
   password = <your desired db password>
   ```
3. If adding a certificate to your load balancer to allow https trafic, go to your registrar (like GoDaddy or IONOS). Type in terraform apply and do not click yes. Get the output for the name servers and update these name servers in your GoDaddy, IONOS, etc. account. 
4. In terraform.tfvars, input your own values

### Automatic steps
1. Type in terraform apply and type in yes to apply when prompted
2. If there is an error coming from the certificate validation, please wait 2 minutes and type in terraform apply again.

### Running in production
1. In your terraform.tfvars, whatever you put for fqdn will be the fully qualified domain name and your app will work on that domain. 

# Instructions to run the app locally
1. Install Node (Google Instructions)

2. Install Dependencies for the App
```sh
npm install
```

3. Run the app
```sh
npm start or docker-compose up
```

(Optional)
```sh
DB_NAME={name_of_db} DB_HOST={host_url_of_db} DB_USER={username_of_db} DB_PASS={password_of_db} npm start
```
to run `/db_healthcheck` endpoint

# CI/CD
* Any time you push to the main branch in github, a continuous integration and delivery process will be initiated to update the app in production. 

