# sshfs_helper

SSHFS helper scripts for mounting remote server directories on to your file system. It 
Parses your ssh config file for servers to mount. Then uses bash auto completion with 
both commands so it is easier to know which servers you can mount.

## How to install
Clone the repo.

cd into the sshfs_helpers directory.

Then run: (It needs sudo, so please inspect the install script first)
```
$ sudo ./install.sh 
```

## How to uninstall
cd into the sshfs_helpers directory

Then run: (It needs sudo, so please inspect the uninstall script first)
```
$ sudo ./uninstall.sh
```

## How to use
### Format the ssh config file 
Here is an example of the formating needed for sshfs helper scripts to parse the config file properly.

[...] denotes a example config value. Replace it with your config value. 

```
Host [server_name]
    User [username]
    Hostname [uri or ip address]

Host [server_name]
    #remotedirpath [The directory path starting from / on the remote machine where you would like to mount to.]
    User [username]
    Hostname [uri or ip address]

Host [server_name]
    #remotedirpath [/home/username/example_mount_directory]
    User [username]
    Hostname [uri or ip address]
    IdentityFile [location of you ssh private key file]

```

### The two commands
(These commands should never be run with sudo)

```
$ mntsshfs
```
and
```
$ umntsshfs
```


### The -t flag
You can use the -t flag to print the sshfs command without executing it.
```
$ mntsshfs -t [server_name]

# The sshfs mount command:
# sshfs [username]@[ip_address]:[remote_mount_dir] [local_mount_dir] -o IdentityFile=[location_of_private_key]

```

```
$ umntsshfs -t [server_name]

# The sshfs unmount command:
# fusermount -u [local_mount_dir]

```


### The -v flag
You can also use the -v flag for verbose output
```
$ mntsshfs -vvv [server_name]

# server to mount: [server_name]
# You computer type is: Linux

# parent directory path: /home/[username]/mnt
# remote directory path: [remote_mount_dir]
#  local directory path: /home/[username]/mnt/[server_name]
#       server username: [username]
#            server uri: [ip_address]
#    identity file path: [location_of_private_key]

# previous_num_of_mounted_dirs =        0
# current_num_of_mounted_dirs  =        1
# Successfully mounted server "[server_name]"
```
