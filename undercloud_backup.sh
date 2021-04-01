#!/usr/bin/env bash
# Bash wapper for ansible-playbook commands to perform ReaR backups 
#
# Adjust this to reflect the base directory for this repository in your system
BASE_DIR=/home/stack/rhosp16_rear_backup_automation

# Script functions
function render_inventory(){
  echo "Rendering inventory files."
  /usr/bin/ansible-playbook playbooks/01_render_inventory_files.yml
  echo "Inventory files have been rendered."
}

function undercloud_backup(){
  /usr/bin/ansible-playbook -i overcloud_inventory.yml \
  playbooks/04_backup_undercloud.yml --tags bar_create_recover_image
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

###################
# START SCRIPT ####
###################
base_dir_check
inventory_exists || render_inventory
undercloud_backup && echo -e "OK: the undercloud has been backed up successfully."
###################
# END SCRIPT ######
###################
