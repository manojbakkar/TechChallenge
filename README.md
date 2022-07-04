<h2> AWS Architecture </h2>
<p> * 1 EC2 instance: t2.micro <p>
<p> * 1 postgres RDS instance: db.t2.micro, Engine version: postgres 12.10
<p> * 1 Application load balancer <p>

<p> EC2 USERDATA will be used to build and start webserver. </p> 


<h3> Security: </h3>
<p> EC2 and RDS should be launched in private subnets and the VMs should be behind the application LB </p>
<p> Only EC2 with defined security group can access RDS and RDS won't have internet access </p>




<h2> Prerequisite </h2>
<p> Before launching Terraform template, aws cli should be installed and configured with proper access key and secret key </p>
<p> Terraform should be installed in your local machine </p>



<h2> STEPS: </h2>

 <p>Clone this repo using command <code>  git clone https://github.com/devbhusal/servian-TechApp-Challenge.git </code></p>
 <p> Go to project folder         <code>  cd servian-TechApp-Challenge </code></p>
 <p>Initialize terraform          <code>  terraform init</code></p>
 <p>Change database and aws setting in terraform.tfvars file </code></p>
 <p>Generate Key pair using        <code> ssh-keygen -f mykey-pair  </code></p>
 <p>View Plan using                <code> terraform plan -var-file="user.tfvars"  </code></p>
 <p>Apply the plan using           <code> terraform apply -var-file="user.tfvars" </code></p>
 
 <p>Wait for atleast 3 mins after provision finished, before typing displayed public IP address in your browser.</p>
 <h3> everything is Automatic. This will provision all needed  aws resources and also build and start webserver using cloud init </h3>

 <p>Destroy the resources          <code> terraform destroy -var-file="user.tfvars" </code></p>


