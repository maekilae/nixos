## STYLE ##
Custom Options: camelCase
Custom Service Names: camelCase
Custom attributes: camelCase

File names: kebab-case

## Structure ##
Folder and module structure

### programs ###
./modules/programs

Programs should have a categoric folder structure (e.g., gaming, cli, terminal, browser, etc.) 
Categories should contain seperate files and modules for most programs and a master module that imports all modules in folder.

<category>/

### system ###
./modules/system

settings contains system settings according to categories which are populated by system level setting modules. 

types contains different system configurations (e.g., desktop, laptop, server-large, server, etc.)

settings/
    <setting>/
types/
    <type>/


### services ###
./modules/services

services contains services (e.g., tailscale, ssh) these should be places in flat style, no subdir's

<service>.nix

### wrappers ###
./modules/wrappers

wrappers contains wrappers for programs that enable configurations, should be placed in a flat style unless the wrapper comes with additional external config files

<wrapper>/
    <wrapper>.nix
    <wrapper-external>
<wrapper>.nix

### hosts ###
./modules/hosts

hosts contains folders containg flat folders/modules that are system specific. The users file should specifiy what users are available for the system as well as what their permissions are. 

users/
    <user>.nix
configuration.nix
flake-parts.nix
hardware.nix

### users ###
Should contain user modules/folders specifiying available program sets, sevices, name, etc.

<user>/
    <user>.nix
    flake-parts.nix

## Building ##
To update, rebuild, switch, or other use ./update.sh script

./update.sh -i to rebuild switch
./update.sh -i -u to update inputs and rebuild, switch

## External Packages ##
External packages packaged by me are (should be placed) in /home/marcus/Dev/anynix-flake
