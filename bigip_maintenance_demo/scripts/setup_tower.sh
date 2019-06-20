#!/bin/bash

BASE_DIR=bigip_maintenance_demo

tower-cli config verify_ssl false
tower-cli config host ansible
tower-cli login admin

## Organization ##
tower-cli organization create --name="F5-Demo"

## Inventory ##
tower-cli inventory create --name="F5-Demo-Inventory" --organization="F5-Demo"
sudo tower-manage inventory_import --source=/home/student1/networking-workshop/lab_inventory/hosts --inventory-name="F5-Demo-Inventory"

## Project ##
tower-cli project create --name="F5-Demo" --description="F5-Demo Project" --scm-type="git" --scm-url="https://github.com/mamurai/Ansible_Demos" --organization="F5-Demo" --wait

## Job Template ##
tower-cli job_template create --name="bigip-config-add" --description="Add Big-ip config" --inventory="F5-Demo-Inventory" --project="F5-Demo" --playbook="${BASE_DIR}/bigip_config_add.yml"
tower-cli job_template create --name="bigip-config-delete" --description="Delete Big-ip config" --inventory="F5-Demo-Inventory" --project="F5-Demo" --playbook="${BASE_DIR}/bigip_config_delete.yml"

