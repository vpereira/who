### Check who was logged in in a specific time frame via ssh

#### Problem:

People connect via ssh to a remote host using a shared user

#### Solution:

Stop to using root user and assign users to every one acessing the remote host,
letting them sudo when root permission is necessary. Done. No tool is needed.

If you however still here, if you have ssh key based authentication and not shared password, then you can use this tool, piping the log from systemd journal
like:

```journalctl -u sshd --utc -o json --since "18 hours ago" | ruby who.rb```

Giving you an output like:

```
not-my-api:~ # journalctl -u sshd --utc -o json --since "18 hours ago" | ruby who.rb
2021-06-21 14:12:41 +0000 - 256 SHA256:1dp5AyXJlGdAJ33DP0Bim+/LxV0es11rYXHx3tZonCov foo@example.org (ED25519)
2021-06-21 15:11:31 +0000 - 4096 SHA256:X30cek6qKP99evjZxbBJynnVY6EoUTLBc5ZO+XXt0L1 bar@example.org (RSA)
not-my-api:~ #
```
