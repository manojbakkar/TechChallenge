<h2> AWS Architecture </h2>
<p> * 1 EC2 instance: t2.micro <p>
<p> * 1 postgres RDS instance: db.t2.micro, Engine version: postgres 12.10
<p> * 1 Application load balancer <p>

<p> EC2 USERDATA will be used to build and start webserver. </p> 

![Servian.png](Servian.png)


<h3> Security: </h3>
<p> EC2 and RDS should be launched in private subnets and the VMs should be behind the application LB </p>
<p> Only EC2 with defined security group can access RDS and RDS won't have internet access </p>




<h2> Prerequisite </h2>
<p>    1. AWS CLI installed, Terraform v0.11.11 <p>
<p>    2. aws configure or attach IAM profile with the node <p>
<p>    3. VPC created in advance <p>
<p>    4. private and public subnets created in advance <p>
<p>    5. SSL certificates created/imported in advance <p>


<h2> STEPS: </h2>

 <p>Clone this repo using command <code>  git clone https://github.com/manojbakkar/TechChallenge.git </code></p>
 <p> Go to project folder         <code>  cd TechChallenge </code></p>
 <p>Initialize terraform          <code>  terraform init</code></p>
 <p>Change database and aws setting in terraform.tfvars file </code></p>
 <p>View Plan using                <code> terraform plan  </code></p>
 <p>Apply the plan using           <code> terraform apply </code></p>
 
 <p>The ALB DNS name will be displayed in terraform apply output. Use that URL with https in your browser.</p>
 
