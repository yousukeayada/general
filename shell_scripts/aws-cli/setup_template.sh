#!/bin/bash

set -euo pipefail

# 色付きの echo
function cecho() {
    local color_name color
    readonly color_name="$1"
    shift
    case $color_name in
        red) color=31 ;;
        green) color=32 ;;
        yellow) color=33 ;;
        blue) color=34 ;;
        cyan) color=36 ;;
        *) error_exit "An undefined color was specified." ;;
    esac
    printf "\033[${color}m%b\033[m" "$*"
}

# このスクリプト自身のディレクトリに移動する
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"


function main() {
    cecho cyan "Create vpc\n"
    cecho green "Input CidrBlock: "
    read VpcCidrBlock
    cecho green "Input VpcName: "
    read VpcName
    aws ec2 create-vpc --cidr-block $VpcCidrBlock --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value='${VpcName}'}]'

    cecho cyan "Create subnet\n"
    VpcId=$(aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Value==`'${VpcName}'`]].VpcId' --output text)
    cecho green "Input CidrBlock: "
    read SubnetCidrBlock
    cecho green "Input SubnetName: "
    read SubnetName
    aws ec2 create-subnet --vpc-id $VpcId --cidr-block $SubnetCidrBlock --availability-zone ap-northeast-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value='${SubnetName}'}]'

    cecho cyan "Create route-table\n"
    cecho green "Input RtbName: "
    read RtbName
    aws ec2 create-route-table --vpc-id $VpcId --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value='${RtbName}'}]'

    cecho cyan "Associate route-table\n"
    RtbId=$(aws ec2 describe-route-tables --query 'RouteTables[?Tags[?Value==`'${RtbName}'`]].RouteTableId' --output text)
    SubnetId=$(aws ec2 describe-subnets --query 'Subnets[?Tags[?Value==`'${SubnetName}'`]].SubnetId' --output text)
    aws ec2 associate-route-table --route-table-id $RtbId --subnet-id $SubnetId

    cecho cyan "Create internet-gateway\n"
    cecho green "Input IgwName: "
    read IgwName
    aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value='${IgwName}'}]'

    cecho cyan "Attach internet-gateway\n"
    IgwId=$(aws ec2 describe-internet-gateways --query 'InternetGateways[?Tags[?Value==`'${IgwName}'`]].InternetGatewayId' --output text)
    aws ec2 attach-internet-gateway --internet-gateway-id $IgwId --vpc-id $VpcId

    cecho cyan "Create route to internet\n"
    aws ec2 create-route --route-table-id $RtbId --destination-cidr-block 0.0.0.0/0 --gateway-id $IgwId

    cecho cyan "Create security group\n"
    cecho green "Input GroupName: "
    read GroupName
    cecho green "Input SgDescription: "
    read SgDescription
    cecho green "Input SgName: "
    read SgName
    aws ec2 create-security-group --group-name $GroupName --description $SgDescription --vpc-id $VpcId --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value='${SgName}'}]'

    cecho cyan "Authorize security-group ingress\n"
    GroupId=$(aws ec2 describe-security-groups --query 'SecurityGroups[?Tags[?Value==`'${SgName}'`]].GroupId' --output text)
    GlobalIp=$(curl ifconfig.io)
    aws ec2 authorize-security-group-ingress --group-id $GroupId --protocol tcp --port 22 --cidr ${GlobalIp}/32

    cecho cyan "Create key-pair\n"
    cecho green "Input KeyName: "
    read KeyName
    cecho green "Input OutputPath: "
    read OutputPath
    aws ec2 create-key-pair --key-name $KeyName --query 'KeyMaterial' --output text > "${OutputPath}"
    chmod 600 "${OutputPath}"

    cecho cyan "Run instance\n"
    cecho green "Input InstanceName: "
    read InstanceName
    aws ec2 run-instances \
    --image-id ami-09b86f9709b3c33d4 \
    --instance-type t2.micro \
    --subnet-id $SubnetId \
    --security-group-ids $GroupId \
    --associate-public-ip-address \
    --key-name $KeyName \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='${InstanceName}'}]'

    cecho cyan "Configure ssh\n"
    PublicIpAddress=$(aws ec2 describe-instances --query 'Reservations[].Instances[?Tags[?Value==`'${InstanceName}'`]].PublicIpAddress' --output text)
    printf "\nHost aws\n" >> ~/.ssh/config
    printf "\tHostName ${PublicIpAddress}\n" >> ~/.ssh/config
    printf "\tUser ubuntu\n" >> ~/.ssh/config
    printf "\tIdentityFile ${OutputPath}\n" >> ~/.ssh/config
    printf "\tPort 22\n" >> ~/.ssh/config

    exit 0
}

main