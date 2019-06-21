#!/bin/bash

BASE_DIR=bigip_maintenance_demo

tower-cli config verify_ssl false
tower-cli config host ansible
tower-cli login admin

## Organization ##
tower-cli organization create --name="F5-Demo"

## Inventory ##
tower-cli inventory create --name="F5-Demo-Inventory" --organization="F5-Demo"
sudo tower-manage inventory_import --source=/home/${USER}/networking-workshop/lab_inventory/hosts --inventory-name="F5-Demo-Inventory"

## Project ##
tower-cli project create --name="F5-Demo" --description="F5-Demo Project" --scm-type="git" --scm-url="https://github.com/mamurai/Ansible_Demos" --organization="F5-Demo" --wait

## Credential ##
tower-cli credential create --name="F5-Demo-Credential" --organization="F5-Demo" --inputs="{"username": "${USER}"}" --credential-type="Machine"

## Job Template ##
tower-cli job_template create --name="bigip-config-add" --description="Add Big-ip config" --inventory="F5-Demo-Inventory" --project="F5-Demo" --playbook="${BASE_DIR}/bigip_config_add.yml"
tower-cli job_template create --name="bigip-config-delete" --description="Delete Big-ip config" --inventory="F5-Demo-Inventory" --project="F5-Demo" --playbook="${BASE_DIR}/bigip_config_delete.yml"
tower-cli job_template create --name="Disabled_Pool-member" --description="Disabled Pool Member" --inventory="F5-Demo-Inventory" --project="F5-Demo" --playbook="${BASE_DIR}/bigip_disabled_pool-member.yml"
tower-cli job_template create --name="Enabled_Pool-member" --description="Enabled Pool Member" --inventory="F5-Demo-Inventory" --project="F5-Demo" --playbook="${BASE_DIR}/bigip_enabled_pool-member.yml"
tower-cli job_template create --name="Webserver1-Maintenance" --description="Webserver1 Maintenance" --inventory="F5-Demo-Inventory" --credential="F5-Demo-Credential" --project="F5-Demo" --playbook="${BASE_DIR}/host1_maintenance.yml"

## Workflow ##
tower-cli workflow create --name="WF-Webserver-Maintenance" --organization="F5-Demo" --description="Webserver Maintenance Demo Workflow"
tower-cli node create -W WF-Webserver-Maintenance --job-template="Disabled_Pool-member"
tower-cli node create -W WF-Webserver-Maintenance --job-template="Webserver1-Maintenance"
tower-cli node create -W WF-Webserver-Maintenance --job-template="Enabled_Pool-member"
tower-cli node associate_success_node 1 2
tower-cli node associate_success_node 2 3
