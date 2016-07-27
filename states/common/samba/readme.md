
After Samba server and client installation,
check registered Samba users:

```
sudo pdbedit -L -v
```

In order to add new Samba user with password, run the following command:

```
sudo smbpasswd -a username
```

Then check what Samba server lists for the newly added user:

```
smbclient -L localhost -U username
```

Normally, each user has their home directory accessible on the file server:

```
smbclient //localhost/username -U username
```

The client command line interface is similar to `ftp`, for example:

*   `ls`

    List current directory.

*   `cd`

    Change current directory.

*   `get path/to/RSRC path/to/LDST`

    Download remote `RSRC` file into local `LDST` file.

*   `put path/to/LSRC path/to/RDST`

    Upload local `LSRC` file into remote `RDST` file.

