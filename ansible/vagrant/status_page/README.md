# Cachet Vagrant

## Makefile

Using this makefile will descrease the amount of time you are stuck waiting by an order of magniutde. 

It is so effective that it is the only current supported method for this project. Just running vagrant up will be ineffective due to run tags in the vagrant file. 

This may change in the future.

### Commands

- `make clean`
	- Destroys vagrant box
- `make base`
	- Creates a backup snapshot
	- Destroys running vagrant vm
	- Creates a new blank vm
	- Runs the general provisioner
	- Runs the base ansible provisioner
	- Creates a 'base' snapshot
- `make core`
	- Creates a backup snapshot
	- Restores to the 'base' snapshot
	- Runs the provisioners and 'base ansible'
	- Creates a 'core' snapshot
- `make setup`
	- Creates a backup snapshot
	- Restores to the 'core' snapshot
	- Runs the provisioners
		- Ansible excludes the base and core tags
- `make all`
	- Runs 'base', 'core', 'setup'
- `make restore`
	- Presents a list of available snapshots that you can restore from

## Access

You should then be able to access cachet by navigating to http://localhost:8080 or http://172.17.0.2