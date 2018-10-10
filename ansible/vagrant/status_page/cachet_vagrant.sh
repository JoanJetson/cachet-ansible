#!/bin/bash
# This script restores to a snapshot of the previous set and reruns the ansible
# Invoked by the Makefile

vm_name="cachet"
mode=$1

# check if $vm_name exists
vagrant status "$vm_name" > /dev/null 2>&1
vm_exists=$?

if [ $mode == "clean" ] ; then
    if [ $vm_exists -eq 0 ] ; then
        echo "$mv_name exists"
        vagrant destroy "$vm_name"
    else
        echo "$vm_name does not exist"
    fi
fi
if [ $mode == "base" ] || [ $mode == "all" ] ; then
    if [ $vm_exists -eq 1 ] ; then
        echo "$vm_name does not exist"
    else
        echo "$vm_name already exists"
        echo "Creating backup snapshot"
        vagrant snapshot save "$vm_name" "$vm_name"_backup --force 
        vagrant destroy "$vm_name" --force
    fi
    echo "Creating blank box"
    vagrant up --no-provision
    echo "Running vagrant provision"
    # Note: them main reason for this is because you can't call the :reload module
    # with --provision-with. It all kind of spawned this rabit hole
    vagrant provision
    echo "Running vagrant provision-with shell,file,status-page-base"
    vagrant provision --provision-with "shell,file,status-page-base"
    echo "Creating snapshot"
    vagrant snapshot save "$vm_name" "$vm_name"_base --force
fi
if [ $mode == "core" ] || [ $mode == "all" ] ; then
    echo "Creating backup snapshot"
    vagrant snapshot save "$vm_name" "$vm_name"_backup --force 
    echo "Restoring VM to the base snapshot" # need to add a check here
    vagrant snapshot restore "$vm_name" "$vm_name"_base --no-provision
    echo "Running vagrant provision-with shell,file,status-page-core"
    vagrant provision --provision-with "shell,file,status-page-core"
    echo "Creating snapshot"
    vagrant snapshot save "$vm_name" "$vm_name"_core --force
fi
if [ $mode == "setup" ] || [ $mode == "all" ] ; then
    echo "Creating backup snapshot"
    vagrant snapshot save "$vm_name" "$vm_name"_backup --force 
    echo "Restoring VM to the core snapshot" # need to add a check here
    vagrant snapshot restore "$vm_name" "$vm_name"_core --no-provision
    echo "Running vagrant provision-with shell,file,status-page-setup"
    vagrant provision --provision-with "shell,file,status-page-setup"
    echo "Creating snapshot"
    vagrant snapshot save "$vm_name" "$vm_name"_setup --force
fi
if [ $mode == "monitor" ] ; then
    echo "Creating backup snapshot"
    vagrant snapshot save "$vm_name" "$vm_name"_backup --force 
    echo "Restoring VM to the core snapshot" # need to add a check here
    vagrant snapshot restore "$vm_name" "$vm_name"_setup --no-provision
    echo "Running vagrant provision-with shell,file,status-page-monitor"
    vagrant provision --provision-with "shell,file,status-page-monitor"
    echo "Creating snapshot"
    vagrant snapshot save "$vm_name" "$vm_name"_monitor --force
fi
if [ $mode == "restore" ] ; then
    if [ $vm_exists -eq 1 ] ; then
        echo "$vm_name does not exist"
        vagrant up --no-provision
    fi
    echo "List of snapshots"
    vagrant snapshot list
    read -p "Select Snapshot to restore: " snapshot_name
    vagrant snapshot restore "$vm_name" "$snapshot_name" --no-provision
fi
