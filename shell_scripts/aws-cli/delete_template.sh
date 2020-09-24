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
    cecho cyan "Terminate instance\n"
    aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,Tags][]'
    cecho green "Input InstanceId: "
    read InstanceId
    aws ec2 terminate-instances --instance-ids $InstanceId

    cecho cyan "Delete key-pair\n"
    aws ec2 describe-key-pairs --query 'KeyPairs[].KeyName'
    cecho green "Input KeyName: "
    read KeyName
    aws ec2 delete-key-pair --key-name $KeyName

    cecho cyan "Delete security-group\n"
    aws ec2 describe-security-groups --query 'SecurityGroups[].[GroupId,Tags][]'
    cecho green "Input GroupId: "
    read GroupId
    aws ec2 delete-security-group --group-id $GroupId

    cecho cyan "Delete subnet\n"
    aws ec2 describe-subnets --query 'Subnets[].[SubnetId,Tags][]'
    cecho green "Input SubnetId: "
    read SubnetId
    aws ec2 delete-subnet --subnet-id $SubnetId

    cecho cyan "Detach internet-gateway\n"
    aws ec2 describe-internet-gateways --query 'InternetGateways[].[InternetGatewayId,Tags][]'
    cecho green "Input InternetGatewayId: "
    read InternetGatewayId
    aws ec2 describe-vpcs --query 'Vpcs[].[VpcId,Tags][]'
    cecho green "Input VpcId: "
    read VpcId
    aws ec2 detach-internet-gateway --internet-gateway-id $InternetGatewayId --vpc-id $VpcId

    cecho cyan "Delete internet-gateway\n"
    aws ec2 delete-internet-gateway --internet-gateway-id $InternetGatewayId

    cecho cyan "Delete route-table\n"
    aws ec2 describe-route-tables --query 'RouteTables[].[RouteTableId,Tags][]'
    cecho green "Input RouteTableId: "
    read RouteTableId
    aws ec2 delete-route-table --route-table-id $RouteTableId

    cecho cyan "Delete vpc\n"
    aws ec2 delete-vpc --vpc-id $VpcId

    exit 0
}

main