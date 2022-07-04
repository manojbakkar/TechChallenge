vpc_id = "" // Pre-requisite

database_name = "postgresDB" // database name

database_user = "postgresuser" //database username

region = "us-west-2"

ami = "ami-08970fb2e5767e3b8" // Pre-requisite. For testing, I've mentioned RHEL base image.

PUBLIC_KEY_PATH = "./mykey-pair.pub"

instance_type = "t2.micro"

instance_class = "db.t2.micro"

private-subnet-1 = "" // Pre-requisite

private-subnet-2 = "" // Pre-requisite

private-subnet-app = "" // Pre-requisite

public-subnet-1 = "" // Pre-requisite

public-subnet-2 = "" // Pre-requisite

Appalb_targetgrp = "App-TargetGroup"

database_password = "" // Pre-requisite
