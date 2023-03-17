# Instructions to run the app
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

# Production
App is hosted at http://interview-load-balancer-1812788571.us-east-1.elb.amazonaws.com using AWS ECS and Fargate 

http://interview-load-balancer-1812788571.us-east-1.elb.amazonaws.com/db_healthcheck works too.
