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

function overcloud_backup(){
  /usr/bin/ansible-playbook -i overcloud_inventory.yml \
  playbooks/05_backup_overcloud.yml --tags bar_create_recover_image
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
    echo "Inventory files do not exist."
    return 1
  fi 
}

function print_help() {
  cat <<EOF 
The script contains wrapped functions of ansible playbook commands for
automating the backup of an RHOSP 16.1 Overcloud control plane with ReaR.

Available options:
  start => Starts the backup of the Overcloud control plane. This will take a
           while to complete based on the disk size of the hosts.

Example usage: ${0} start
EOF
}

###################
# START SCRIPT ####
###################
case "$1" in
  start)
    base_dir_check
    inventory_exists || render_inventory
    overcloud_backup && echo -e "OK: the Overcloud controllers has been backed up successfully."
    exit 0
  ;;
  *)
    base_dir_check
    print_help
esac
###################
# END SCRIPT ######
###################
