# Learn Terraform - Lambda functions and API Gateway

Once applied the terraform, check if this is working quering the api url 

```
curl "$(terraform output -raw base_url)/hello"
{"message":"Hello, World!"}
```