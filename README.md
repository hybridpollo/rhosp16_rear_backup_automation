### Red Hat Openstack Platform 16.1 Ansible Driven Backup Automation Using ReaR

### Disclaimer
The playbooks in this repository are free to use and come without warranty or
support of Red Hat or the repository owner.

### About this repository
This repository contains a set of playbooks used to automate the installation
and configuration of the Relax and Recover(ReaR) software for a  a Red Hat 
OpenStack Platform 16.1 Undercloud and Overcloud Control Plane following
practices as documented in [Red Hat OpenStack Platform 16.1: Undercloud and Control Plane Backup and Restore](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/index).

### About Relax and Recover
The Relax-and-Recover is a Linux disaster recovery solution. ReaR is the
documented solution for backing up and restoring a Red Hat OpenStack Undercloud
or Overcloud as documented in [Red Hat OpenStack Platform 16.1: Undercloud and Control Plane Backup and Restore](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/index).

For additional information on the Relax-and-Recover tool check the community
product page: https://relax-and-recover.org/


### Requisites
* Ansible >= 2.9
* Access to a functioning Undercloud and Overcloud. This is after all our target backup environments.
* A Red Hat Enterprise Linux 8 server with suffient storage for backup data for the Undercloud and Overcloud baackup images. This will be the remote backup host.
* Network connectivity from the Undercloud and Overcloud hosts to the 
  backup server.
** The ReaR backup process in the Undercloud and Overcloud temporarily mounts an
NFS filesystem to store the backup images to a remote location ( The backup
server) for backup and storage of the images.
* Passwordless ssh authentication from the Undercloud host to the ReaR backup host.

For additional information refer to the [Introduction to Undercloud and Control
Plane Backup and Restore documentation.](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/introduction-to-undercloud-and-control-plane-back-up-and-restore_osp-ctlplane-br)

### Usage
#### Configuring the ReaR Backup Server and Clients
__*Note:*__ These playbooks are designed to be executed from the
Undercloud/Director node as it uses the '*backup-and-restore*' Ansible role.
This role is installed as part of the tripleo-ansible package on an Undercloud
deployment. 

- Configure passwordless ssh from Undercloud to the ReaR backup server: 
   - `ssh-copy-id root@backup.server`
- Render the ansible inventories:
   - `ansible-playbook playbooks/01_render_inventory_files.yml`
- Configure the ReaR backup server:
   - `ansible-playbook -i rear_backup_server_inventory.yml playbooks/02_rear_backup_server_setup.yml --tags bar_setup_nfs_server`
- Configure the ReaR backup client in the Undercloud and Overcloud Controllers:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/03_rear_backup_client_setup.yml --tags bar_setup_rear`

The base directory of this repository also contains a set of bash 
wrapper scripts to help with the above:
- backup_setup.sh: Contains the wrappers for configuring the rear backup
  server and clients

#### Backing up the Undercloud
- Execute the playbooks/04_backup_undercloud.yml including the **bar_create_recover_image** ansible tag:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/04_backup_undercloud.yml --tags bar_create_recover_image`
   - Playbook execution time is dependent on the size of the disk size of the Undercloud

The base directory of this repository also contains a set of bash 
wrapper scripts to help with the above:
- backup_undercloud.sh: Contains the wrappers to begin the ReaR backup on the Undercloud

#### Backing up the Overcloud
- Execute the playbooks/05_backup_overcloud.yml including the **bar_create_recover_image** ansible tag:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/04_backup_undercloud.yml --tags bar_create_recover_image`
   - Playbook execution time is dependent on the size of the disk size of the
     Overcloud as well as the number of OpenStack controllers. A 1x node Controlle cluster will always be significantly shorter than a 3x node Controller cluster

The base directory of this repository also contains a set of bash 
wrapper scripts to help with the above:
- backup_overcloud.sh: Contains the wrappers to begin the ReaR backup on the Overcloud

#### Restoring the Undercloud and Overcloud
To restore the Undercloud or Overcloud controllers follow the procedures as documented in [Chapter 5: Restoring the Undercloud and Control Plane Nodes](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/restoring-the-undercloud-and-control-plane-nodes_osp-ctlplane-br). 
