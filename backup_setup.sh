#!/usr/bin/env bash
# Bash wapper for ansible-playbook commands to configure a ReaR
# backup server and clients
#
# Adjust this to reflect the base directory for this repository in your system
BASE_DIR=/home/stack/rhosp16_rear_backup_automation


function render_inventory(){
  echo "Rendering inventory files."
  /usr/bin/ansible-playbook playbooks/01_render_inventory_files.yml
  echo "Inventory files have been rendered."
}

function rear_server_config(){
  /usr/bin/ansible-playbook -i rear_backup_server_inventory.yml \
  playbooks/02_rear_backup_server_setup.yml --tags bar_setup_nfs_server
}

function rear_client_config(){
  /usr/bin/ansible-playbook -i overcloud_inventory.yml \
  playbooks/03_rear_backup_client_setup.yml --tags bar_setup_rear
}

function base_dir_check(){
  if [[ "${PWD}" != "${BASE_DIR}" ]]; then
    echo "ERROR: Script must be executed from ${BASE_DIR}"
    exit 1
  fi 
}

function inventory_exists(){
  ls ${BASE_DIR}/*_inventory.yml > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "ERROR: Inventory files do not exist."
    return 1
  fi 
}

function print_help() {
  cat <<EOF 
The script contains wrapped functions of ansible playbook commands for 
automating the install of the of ReaR backup components for RHOSP 16.1.
This wrapper takes a single argument per invocation: 

Available options:
  configure-rear-server => Executes the Ansible playbook to configure the ReaR server
  configure-rear-client => Executes the Ansible playbook to configure the ReaR clients

Example usage: ${0} configure-rear-server
EOF
}

###################
# START SCRIPT ####
###################
case "$1" in
  configure-rear-server)
    base_dir_check
    inventory_exists || render_inventory
    rear_server_config && echo -e "OK: ReaR server has been configured successfully."
    exit 0
  ;;
  configure-rear-client)
    base_dir_check
    inventory_exists || render_inventory
    rear_client_config && echo -e "OK: ReaR clients have been configured successfully."
    exit 0
  ;;
  *)
    base_dir_check
    print_help
esac
###################
# END SCRIPT ######
###################
