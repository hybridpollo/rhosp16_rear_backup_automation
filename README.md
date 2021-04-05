### Red Hat Openstack Platform 16.1 Ansible Driven Backup Automation Using ReaR

### Disclaimer
The playbooks in this repository are free to use and come without warranty or
support of Red Hat or the repository owner.

### About this repository
This repository contains Ansible playbooks for the installation
and configuration of the Relax and Recover(ReaR) software used for a Red Hat 
OpenStack Platform 16.1 Undercloud and Overcloud Control Plane backup procedure following
practices as documented in [Red Hat OpenStack Platform 16.1: Undercloud and Control Plane Backup and Restore](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/index).

### About Relax and Recover
The Relax-and-Recover is a flexible baremetal and virtual machine Linux disaster recovery solution. ReaR is the
documented solution for backing up and restoring a Red Hat OpenStack Undercloud
or Overcloud as describe in the [Red Hat OpenStack Platform 16.1: Undercloud and Control Plane Backup and Restore](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/index) documentation.

For additional information and a complete list of features and capabilities of the Relax-and-Recover tool check the 
projects page: https://relax-and-recover.org/

### Requisites
* Ansible >= 2.9
* Access to a functioning Undercloud and Overcloud. This is after all our target backup environments.
* A Red Hat Enterprise Linux 8 server with sufficient storage to accommodate the Undercloud and Overcloud backup images. This server will act as the remote backup host.
* Network connectivity from the Undercloud and Overcloud hosts to the 
  remote backup host.
** The ReaR backup process in the Undercloud and Overcloud temporarily mounts an
NFS filesystem to store the backed up images to the ReaR backup host. 
* Passwordless ssh authentication from the Undercloud host to the ReaR backup host as the root or a user with elevated privileges for the purposes of automation using Ansible.

For additional information refer to the [Introduction to Undercloud and Control
Plane Backup and Restore](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/introduction-to-undercloud-and-control-plane-back-up-and-restore_osp-ctlplane-br) documentation.

### Usage
#### Configuring the ReaR Backup Server and Clients
__*Note:*__ These playbooks are designed for execution from the
Undercloud/Director node as it uses the *backup-and-restore* Ansible role.
This role is installed as part of the tripleo-ansible package on an Undercloud
deployment. 

- Render the Ansible inventories:
   - `ansible-playbook playbooks/01_render_inventory_files.yml`
- Configure the ReaR backup server:
   - `ansible-playbook -i rear_backup_server_inventory.yml playbooks/02_rear_backup_server_setup.yml --tags bar_setup_nfs_server`
- Configure the ReaR backup client in the Undercloud and Overcloud Controllers:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/03_rear_backup_client_setup.yml --tags bar_setup_rear`

#### Example: Backing up the Undercloud
- Execute the playbooks/04_backup_undercloud.yml including the **bar_create_recover_image** ansible tag:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/04_backup_undercloud.yml --tags bar_create_recover_image`
   - Playbook execution time is dependent on the size of the disk size of the Undercloud

#### Example: Backing up the Overcloud
- Execute the playbooks/05_backup_overcloud.yml including the **bar_create_recover_image** ansible tag:
   - `ansible-playbook -i overcloud_inventory.yml playbooks/04_backup_undercloud.yml --tags bar_create_recover_image`
   - Playbook execution time is dependent on the size of the disk size of the
     Overcloud as well as the number of OpenStack controllers. A 1x node Controlle cluster will always be significantly shorter than a 3x node Controller cluster

The repositorys' base directory also contains a set of bash scripts using Ansible playbook wrappers to facilitate the functionality as described on the previous section: 

`backup_setup.sh`: Configures the rear backup server and clients.  

`backup_undercloud.sh`: Starts the backup of the Undercloud. 

`backup_overcloud.sh`: Starts the backup of the Overcloud. 


#### Restoring the Undercloud and Overcloud
To restore the Undercloud or Overcloud controllers follow the procedures as documented in [Chapter 5: Restoring the Undercloud and Control Plane Nodes](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/undercloud_and_control_plane_back_up_and_restore/restoring-the-undercloud-and-control-plane-nodes_osp-ctlplane-br). 
