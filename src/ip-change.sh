#! /bin/bash

New_Cidr=$new_source_ip
Security_Group_ID=$securityGroup_id

####################Ingress Rule Function##############################################
ingress_func() {
  if [[ "$Security_Group_ID" == "" ]]
  then
    echo "You must supply a security group ID and IP range."
    exit 1
  fi

  if [[ "$PROTOCOL" == "-1" ]]
  then
    Remove_Rule=$(aws ec2 revoke-security-group-ingress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp='"$IP"'}]')
    echo $Remove_Rule

    Add_rule=$(aws ec2 authorize-security-group-ingress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp='"$New_Cidr"',Description='"$DESCRIPTION"'}]')
    echo $Add_rule 
  else
    Remove_Rule=$(aws ec2 revoke-security-group-ingress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=$FROMPORT,ToPort=$TOPORT,IpRanges='[{CidrIp='"$IP"'}]')
    echo $Remove_Rule
  
    Add_rule=$(aws ec2 authorize-security-group-ingress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=$FROMPORT,ToPort=$TOPORT,IpRanges='[{CidrIp='"$New_Cidr"',Description='"$DESCRIPTION"'}]')
    echo $Add_rule
  fi 
}

####################Egress Rule Function###############################################
egress_func() {
  if [[ "$Security_Group_ID" == "" ]]
  then
    echo "You must supply a security group ID and IP range."
    exit 1
  fi

  if [[ "$PROTOCOL" == "-1" ]]
  then
    Remove_Rule=$(aws ec2 revoke-security-group-egress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp='"$IP"'}]')
    echo $Remove_Rule

    Add_rule=$(aws ec2 authorize-security-group-egress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp='"$New_Cidr"',Description='"$DESCRIPTION"'}]')
    echo $Add_rule 
  else
    Remove_Rule=$(aws ec2 revoke-security-group-egress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=$FROMPORT,ToPort=$TOPORT,IpRanges='[{CidrIp='"$IP"'}]')
    echo $Remove_Rule
  
    Add_rule=$(aws ec2 authorize-security-group-egress --group-id $Security_Group_ID --ip-permissions IpProtocol=$PROTOCOL,FromPort=$FROMPORT,ToPort=$TOPORT,IpRanges='[{CidrIp='"$New_Cidr"',Description='"$DESCRIPTION"'}]')
    echo $Add_rule
  fi 
}

####################Ingress Main Execution#############################################
ingress_security_group_rules=$(aws ec2 describe-security-groups --group-ids $Security_Group_ID --query "SecurityGroups[].[IpPermissions[*]][0][0]")
ingress_number_of_rules=$(echo "$ingress_security_group_rules" | jq '. | length')

for (( j=0 ; j<$ingress_number_of_rules ; j++));
do
  rules=$(aws ec2 describe-security-groups --group-ids $Security_Group_ID --query "SecurityGroups[].[IpPermissions[*]][0][0][$j]" )
  PROTOCOL=$(echo "$rules" | jq -r '.IpProtocol')
  if [[ $PROTOCOL == "-1" ]]
  then
    IP=$(echo "$rules" | jq -r '.IpRanges[].CidrIp')
  else
    FROMPORT=$(echo "$rules" | jq -r '.FromPort')
    TOPORT=$(echo "$rules" | jq -r '.ToPort')
    PROTOCOL=$(echo "$rules" | jq -r '.IpProtocol')
    IP=$(echo "$rules" | jq -r '.IpRanges[].CidrIp')
  fi

  if [[ $IP == "0.0.0.0/0" ]]
  then
    DESCRIPTION="Modified by Terraform-shell script"
    RULE="ingress"

    case "$RULE" in
    ingress)
      ingress_func ;;
    *) echo "Invalid action."
    exit 1 ;;
    esac
  else
    echo "skip: Source IP is not 0.0.0.0/0"
  fi
done

####################Egress Main Execution##############################################
egress_security_group_rules=$(aws ec2 describe-security-groups --group-ids $Security_Group_ID --query "SecurityGroups[].[IpPermissionsEgress[*]][0][0]")
egress_number_of_rules=$(echo "$egress_security_group_rules" | jq '. | length')
echo "Total Number of Egress Rules = $(($egress_number_of_rules+1))"

for (( i=0 ; i<$egress_number_of_rules ; i++));
do
  rules=$(aws ec2 describe-security-groups --group-ids $Security_Group_ID --query "SecurityGroups[].[IpPermissionsEgress[*]][0][0][$i]" )
  PROTOCOL=$(echo "$rules" | jq -r '.IpProtocol')
  if [[ $PROTOCOL == "-1" ]]
  then
    IP=$(echo "$rules" | jq -r '.IpRanges[].CidrIp')
  else
    FROMPORT=$(echo "$rules" | jq -r '.FromPort')
    TOPORT=$(echo "$rules" | jq -r '.ToPort')
    PROTOCOL=$(echo "$rules" | jq -r '.IpProtocol')
    IP=$(echo "$rules" | jq -r '.IpRanges[].CidrIp')
  fi

  if [[ $IP == "0.0.0.0/0" ]]
  then
    DESCRIPTION="Modified by Terraform-shell script"
    RULE="egress"

    case "$RULE" in
    egress)
      egress_func ;;
    *) echo "Invalid action." 
    exit 1 ;;
    esac
  else
    echo "skip: Source IP is not 0.0.0.0/0"
  fi

done
