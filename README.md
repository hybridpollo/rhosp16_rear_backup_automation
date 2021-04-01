### Red Hat Openstack Platform 16.1 Ansible Driven Backup Automation

#### About
This repository contains a set of playbooks used to automate the installation
and configuration of the Relax and Recover(ReaR) software for a  a Red Hat 
OpenStack Platform 16.1 Undercloud and Overcloud Control Plane following
practices as documented in [Red Hat OpenStack Platform 16.1: Undercloud and Control Plane Backup and Restore](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/index).

#### Requisites
* Ansible => 2.9
* Access to a functioning Undercloud and Overcloud. This is afterall the resources we want
* A Red Hat Enterprise Linux 8 server with suffient storage to store backup
  images of the Undercloud and Overcloud controllers. This will be the ReaR backup host
* Network connectivity from the Undercloud and Overcloud hosts to the ReaR
  backup server.
** The ReaR backup process in the Undercloud and Overcloud temporarily mounts an
NFS filesystem to store the backup images to a remote location ( The backup
server).
  to back up
* Passwordless ssh authentication from the Undercloud host to the ReaR backup host.

For additional information refer to the [Introduction to Undercloud and Control
Plane Backup and Restore documentation.](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/introduction-to-undercloud-and-control-plane-back-up-and-restore_osp-ctlplane-br)

#### Usage
##### Configuring the ReaR Backup Server and Clients
1. Configure passwordless ssh from Undercloud to the backup server: 
   - `ssh-copy-id root@backup.server`
2. Render the ansible inventories:
   - `ansible-playbook playbooks/01_render_inventory_files.yml`
3. Configure the ReaR backup server:
   - `ansible-playbook -i rear_backup_server_inventory.yml playbooks/02_rear_backup_server_setup.yml --tags bar_setup_nfs_server`
4. Configure the ReaR backup client in the Undercloud and Overcloud Controllers:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/03_rear_backup_client_setup.yml --tags bar_setup_rear`

##### Backing up the Undercloud
1. Execute the playbooks/04_backup_undercloud.yml including the **bar_create_recover_image** ansible tag:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/04_backup_undercloud.yml --tags bar_create_recover_image`
   - Playbook execution time is dependent on the size of the disk size of the Undercloud

##### Backing up the Overcloud
1. Execute the playbooks/05_backup_overcloud.yml including the **bar_create_recover_image** ansible tag:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/04_backup_undercloud.yml --tags bar_create_recover_image`
   - Playbook execution time is dependent on the size of the disk size of the
     Overcloud. 

#### Disclaimer
The playbooks in this repository are free to use and come without warranty or
support of Red Hat or the repository owner.
