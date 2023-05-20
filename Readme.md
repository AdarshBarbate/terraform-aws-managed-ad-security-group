On creation of AWS Managed Active Directory, aws provides one defualt security group.
The security group ports are wide open to anywhere
We can change that ip from the restrictive IP which we want

# Pre-requisite

Only pass your new cidr block which will be replaced by 0.0.0.0/0

# Script execution

I created one shell script which will triggered by terraform null resource.
The script will run through each and every rules inbound and outbound both.
This shell script will delete only the old rules having 0.0.0.0/0 ip in it. No other rule will be changed.
After deleting it will add new rule with same ports but with new cidr which you will pass.
This works for all type of ports having 0.0.0.0/0 as source ip.