## Introduction

Note that the parameters for each bundle are described in the bundle code. See the meta promises and the _params_ data variable.

## Installing EFL

See [INSTALL.md](INSTALL.md)

## Deleting files

Use the bundle efl_delete_files. Here is a data file that deletes all files in /tmp older than 8 days and all files in /var/cfengine/outputs older than 1 day for members of the alix class.

```
[
   {
      "negate_match" : "no",
      "file_promiser" : "/tmp",
      "recurse_level" : "inf",
      "class" : "any",
      "file_age" : "8",
      "promisee" : "Neil Watson",
      "leaf_regex" : ".*"
   },
   {
      "file_age" : "1",
      "leaf_regex" : ".*",
      "promisee" : "Neil Watson",
      "file_promiser" : "/var/cfengine/outputs",
      "negate_match" : "no",
      "class" : "alix",
      "recurse_level" : "inf"
   }
]
```

When the parameter negate_match is _no_ anything that matches the leaf_regex will be deleted. When set to yes, anything that does not match will be deleted.

## Promising file permissions

Use the bundle efl_file_perms. This sample data, taken from Delta Hardening (found elsewhere in the repository), promises permissions on /etc/passwd and /etc/group.

```
[
   {
      "mode" : "0644",
      "class" : "redhat",
      "group" : "root",
      "negate" : "no",
      "leaf_regex" : ".*",
      "owner" : "root",
      "recurse_level" : "no",
      "file_promiser" : "/etc/passwd",
      "promisee" : "nsa_rhel5 v4.2 sec 2.2.3.1"
   },
   {
      "owner" : "root",
      "recurse_level" : "no",
      "file_promiser" : "/etc/group",
      "promisee" : "nsa_rhel5 v4.2 sec 2.2.3.1",
      "mode" : "0644",
      "class" : "redhat",
      "group" : "root",
      "negate" : "no",
      "leaf_regex" : ".*"
   }
]
```

Negate works just like negat_match in efl_delete_files.

## Promising Linux kernel settings

### Live kernel settings

Use the bundle efl_sysctl_live. This sample data is taken from Delta Hardening.

```
[
   {
      "promisee" : "nsa_rhel5 v4.2 sec 2.2.4.2, 2.2.4.2.1",
      "class" : "redhat",
      "value" : "0",
      "variable" : "fs.suid_dumpable"
   },
   {
      "variable" : "kernel.exec-shield",
      "value" : "1",
      "class" : "redhat",
      "promisee" : "nsa_rhel5 v4.2 sec 2.2.4.3, 2.2.4.3.1"
   },
   {
      "class" : "redhat",
      "promisee" : "nsa_rhel5 v4.2 sec 2.2.4.3, 2.2.4.3.1",
      "variable" : "kernel.randomize_va_space",
      "value" : "1"
   }
]
```

This bundle uses sysctl to test and make needed corrections.

### Sysctl.conf kernel settings

Use the bundle efl_sysclt_conf_file. The parameter file format is exactly the same as the efl_sysctl_live bundle and in practice use the same file to promise both boot time and running settings.

## Promising bundle sequence

Rather than creating a list for the bundlesequence, or creating a long bundle of method calls, use the bundle efl_main. See [INSTALL.md](INSTALL.md) for more details.

## Promising the contents of a file

### Using a Template

Use the bundle efl_edit_template to promise a file from a template. This bundle promises a complete file, deleting the old one. EFL does not edit files in place, conserving old content. Such practices are considered poor.

```
[
   {
      "promiser_file" : "/etc/sudoers",
      "mode" : "600",
      "promisee" : "nsa_rhel5 v4.2 sec 2.3.1.3",
      "owner" : "root",
      "template" : "/var/cfengine/sitefiles/etc/sysconfig/sudoers.tmp",
      "server" : "g.policy_hubs",
      "group" : "root",
      "class" : "redhat"
   },
   {
      "mode" : "644",
      "promiser_file" : "/etc/issue",
      "group" : "root",
      "class" : "redhat",
      "template" : "/var/cfengine/sitefiles/etc/issue.tmp",
      "server" : "g.policy_hubs",
      "owner" : "root",
      "promisee" : "nsa_rhel5 v4.2 sec 2.3.7.1"
   }
]
```

The bundle automatically copies the template from the server listed. The server parameter must be the name of a list. This allows for redundant servers. For example:

```
bundle agent g
{
   vars:
      "policy_hubs" slist => { "${sys.policy_hub}", "192.0.2.100" };
}
```

Where 192.0.2.100 is another CFEngine server, but not the one that the agent is bootstrapped to.

The extension of the template file will determine if it is treated as a CFEngine template (.tmp) or a mustache template (.mus).

### Copying a file

The bundle efl_copy_files will promise the contents of a file using a straight copy rather than a template.

```
[
   {
      "owner" : "root",
      "class" : "install_nwatson_gpg_key",
      "server" : "list_backup.policy_servers",
      "group" : "root",
      "file_promiser" : "/root/neilhwatson.gpg",
      "encrypt" : "no",
      "promisee" : "Backups",
      "file_source" : "${sys.workdir}/sitefiles/misc/neilhwatson.gpg",
      "leaf_regex" : ".*",
      "mode" : "600"
   },
   {
      "group" : "root",
      "file_promiser" : "/etc/apt/cfengine-gpg.key",
      "class" : "install_cfengine_apt_key",
      "owner" : "root",
      "server" : "list_backup.policy_servers",
      "leaf_regex" : ".*",
      "mode" : "644",
      "encrypt" : "no",
      "file_source" : "${sys.workdir}/sitefiles/apt/cfengine-gpg.key",
      "promisee" : "CFEngine"
   }
]
```

The server parameter is a list just like efl_edit_template. This copy will be recursive if the promiser ends in '/.'.

## Enabling services

Use the bundle efl_enable_service. This bundle uses the service or systemctl command if available.

```
[
   {
      "promisee" : "nsa_rhel5 v4.2 sec 3.3.15.3",
      "class" : "redhat",
      "service" : "cpuspeed"
   },
   {
      "promisee" : "nsa_rhel5 v4.2 sec 2.1.1.6",
      "class" : "redhat",
      "service" : "iptables"
   },
   {
      "class" : "redhat",
      "service" : "irqbalance",
      "promisee" : "nsa_rhel5 v4.2 sec 3.3.3"
   }
]
```

## Disabling services

Use the bundle efl_disable_service. This bundle uses the service or systemctl command if available.

```
[
   {
      "class" : "redhat",
      "service" : "snmpd",
      "promisee" : "nsa_rhel5 v4.2 sec 3.20.1, nist sp 800-123 sec 4.2.1"
   },
   {
      "service" : "squid",
      "promisee" : "nsa_rhel5 v4.2 sec 3.19.1, nist sp 800-123 sec 4.2.1",
      "class" : "redhat"
   },
   {
      "class" : "redhat",
      "service" : "smb",
      "promisee" : "nsa_rhel5 v4.2 sec 3.18.1, nist sp 800-123 sec 4.2.1"
   }
]
```

## Promising a running service

The bundle efl_start_service will run the given command if a process is not running.


```
[
   {
      "restart_cmd" : "/usr/sbin/service opennms restart",
      "promisee" : "monitoring",
      "process_regex" : ".+java.+opennms.*",
      "class" : "scope"
   },
   {
      "restart_cmd" : "/usr/sbin/service delta_reporting start",
      "promisee" : "delta reporting demo",
      "class" : "ettin",
      "process_regex" : "/opt/delta_reporting/app/DeltaR.pl"
   },
   {
      "restart_cmd" : "service postgresql restart",
      "promisee" : "delta reporting demo",
      "process_regex" : "/usr/lib/postgresql/9\\.3/bin/postgres -D.*",
      "class" : "ettin"
   }
]
```

## Promising a configured and running service

The bundle efl_service promises a confguration file, template or straight copy, and a running service.

```
[
   {
      "encrypt" : "no",
      "process_regex" : "ntpd -u ntp:ntp -p /var/run/ntpd\\.pid -g",
      "config_file" : "/etc/ntp.conf",
      "class" : "redhat_6|centos_6",
      "restart_cmd" : "/etc/init.d/ntpd restart",
      "mode" : "644",
      "group" : "root",
      "promisee" : "nsa_rhel5 v4.2 sec 3.10",
      "template" : "yes",
      "server" : "efl.policy_servers",
      "owner" : "root",
      "config_file_src" : "/var/cfengine/sitefiles/etc/ntp.conf.tmp"
   },
   {
      "restart_cmd" : "/etc/init.d/ntpd restart",
      "mode" : "644",
      "promisee" : "nsa_rhel5 v4.2 sec 3.10",
      "group" : "root",
      "encrypt" : "no",
      "process_regex" : "ntpd -x -u ntp:ntp -p /var/run/ntpd.pid -g",
      "config_file" : "/etc/ntp.conf",
      "class" : "redhat_5|centos_5",
      "template" : "yes",
      "server" : "efl.policy_servers",
      "config_file_src" : "/var/cfengine/sitefiles/etc/ntp.conf.tmp",
      "owner" : "root"
   },
   {
      "process_regex" : "/usr/sbin/sshd",
      "encrypt" : "yes",
      "config_file" : "/etc/ssh/sshd_config",
      "class" : "redhat",
      "mode" : "640",
      "restart_cmd" : "/etc/init.d/sshd restart",
      "group" : "root",
      "promisee" : "nsa_rhel5 v4.2 sec 3.5.2",
      "template" : "yes",
      "config_file_src" : "/var/cfengine/sitefiles/etc/ssh/sshd_config.tmp",
      "owner" : "root",
      "server" : "efl.policy_servers"
   }
]
```

The restart command is issued if the configuration changes or if the process is not running. The server parameter requires a list name, and the template extension determines if the template is a CFEngine (.tmp) or mustache (.mus) template.

There is also efl_service_recurse works the same as efl_service, but will recursively copy multiple configuration files.

```
[
   {
      "promisee" : "thewavesbeachhouse.ca",
      "process_regex" : "/var/www/cottage/app/CottageS.pl",
      "server" : "list_backup.policy_servers",
      "encrypt" : "no",
      "group" : "cottage",
      "owner" : "cottage",
      "class" : "mercury",
      "restart_cmd" : "su - cottage /var/www/cottage/app/script/start",
      "mode" : "700",
      "config_dir_src" : "${sys.workdir}/cottage_site/app",
      "config_dir" : "/var/www/cottage/app"
   }
]
```

Again the server parameter requires the name of a list.

## Promising installed or removed software

The bundle efl_packages promises to add or remove a package.

```
[
   {
      "architecture" : "*",
      "class" : "redhat",
      "promisee" : "nsa_rhel5 v4.2 sec 2.3.1.3, nist sp 800-123 sec 4.2.1",
      "package_name" : "sudo",
      "package_version" : "0",
      "package_policy" : "add"
   },
   {
      "architecture" : "*",
      "promisee" : "nsa_rhel5 v4.2 sec 2.3.3.7, nist sp 800-123 sec 4.2.1",
      "class" : "redhat",
      "package_name" : "pam_ccreds",
      "package_version" : "0",
      "package_policy" : "delete"
   },
   {
      "package_name" : "xinetd",
      "promisee" : "nsa_rhel5 v4.2 sec 3.2.1, nist sp 800-123 sec 4.2.1",
      "class" : "redhat",
      "architecture" : "*",
      "package_policy" : "delete",
      "package_version" : "0"
   }
]
```

This bundle uses package bodies from the CFEngine standard library. Package promises can be unreliable the more complicated they are. There is an alternative EFL bundle, efl_packages_via_cmd, that uses apt-get or yum commands promises instead of packages promises. The performance is poorer, but it is more reliable. The paramater file is the same for both bundles.

## Promising links

The bundle efl_links promises links.

```
[
   {
      "link_name" : "${sys.workdir}/cf3.${sys.uqhost}.runlog",
      "promisee" : "CFEngine",
      "class" : "oort",
      "link_type" : "symlink",
      "target" : "/dev/null"
   },
   {
      "promisee" : "CFEngine",
      "link_name" : "${sys.workdir}/cfagent.${sys.fqhost}.log",
      "class" : "oort",
      "target" : "/dev/null",
      "link_type" : "symlink"
   }
]
```

## Promising revision controled file

Use the bundle efl_rcs_pull to promise local working copies from a RCS system. This bundle will either update a functioning working copy or checkout a new copy if there is any problem.

```
[
   {
      "mode" : "644",
      "checkout_cmd" : "/usr/bin/git clone http://github.com/cfengine/core.git",
      "promisee" : "CFEngine",
      "update_cmd" : "/usr/bin/git reset --hard HEAD && /usr/bin/git pull",
      "class" : "ettin",
      "group" : "neil",
      "owner" : "neil",
      "dest_dir" : "/home/neil/src/cfengine/core"
   },
   {
      "mode" : "644",
      "checkout_cmd" : "/usr/bin/git clone http://github.com/cfengine/documentation.git",
      "promisee" : "CFEngine",
      "update_cmd" : "/usr/bin/git reset --hard HEAD && /usr/bin/git pull",
      "class" : "ettin",
      "group" : "neil",
      "owner" : "neil",
      "dest_dir" : "/home/neil/src/cfengine/documentation"
   }
]
```

## Creating namespace strings

The bundle efl_global_strings allows you to define namespace, a.k.a global, strings.


```
[
   {
      "value" : "${sys.workdir}/repositories",
      "class" : "any",
      "name" : "repos",
      "promisee" : "cfengine masterfiles"
   },
   {
      "value" : "sun",
      "name" : "day",
      "promisee" : "Days of the week",
      "class" : "Sunday"
   },
   {
      "promisee" : "Days of the week",
      "name" : "day",
      "class" : "Monday",
      "value" : "mon"
   }
]
```

The strings are created using the policy _free_ so a later definition will override an earlier one.

## Creating classes

There are also many bundles to help define namespace classes.

### Using IPrange

The bundle efl_class_iprange uses the CFEngine function _iprange_.

```
[
   {
      "class_to_set" : "my_dmz",
      "ip_range" : "192.0.2.0/24",
      "promisee" : "dmz infosec"
   },
   {
      "class_to_set" : "devel_network",
      "ip_range" : "10.0.2.0/24",
      "promisee" : "developement"
   }
]
```

### Using Classmatch

The bundle efl_class_classmatch uses the CFEngine fucntion _classmatch_.

```
[
   {
      "class_to_set" : "my_dmz",
      "regex" : "ipv4_192_0_2_0",
      "promisee" : "dmz infosec"
   },
   {
      "class_to_set" : "devel_network",
      "regex" : "ipv4_10_0_[2,3]_0",
      "promisee" : "developement"
   }
]
```

### Using class expressions

The bundle efl_class_expression makes classes using standard CFEngine class expressions.

```
[
   {
      "class_to_set" : "my_dmz",
      "expression" : "ipv4_192_0_3_0|ipv4_192_0_2_0",
      "promisee" : "dmz infosec"
   },
   {
      "class_to_set" : "devel_network",
      "expression" : "ipv4_10_0_2_0.!qa_host",
      "promisee" : "developement"
   }
]
```

### Using hostnames

Use the bundle efl_class_hostname2 to make classes if the host's short hostname (${sys.uqhost}) matches the given list.

```
[
   {
      "class_to_set" : "my_dmz",
      "hostname" : [ "blue", "red", "yellow" ],
      "promisee" : "dmz infosec"
   },
   {
      "class_to_set" : "devel_network",
      "hostname" : [ "jupiter", "mars", "venus" ],
      "promisee" : "developement"
   }
]
```

### Using returnszero

Use the bundle efl_class_returnszero to make classes if the given command returns zero, or not.

```
[
   {
      "class_to_set" : "install_nwatson_gpg_key",
      "command" : "/usr/bin/gpg --list-key 60X39R8 > /dev/null",
      "class" : "any",
      "promisee" : "Backups",
      "shell" : "useshell",
      "zero" : "no"
   },
   {
      "class_to_set" : "start_shorewall6",
      "command" : "/sbin/shorewall6 status > /dev/null",
      "promisee" : "shorewall6",
      "class" : "shorewall6_host",
      "shell" : "useshell",
      "zero" : "no"
   }
]

```

The _zero_ parameter means set class if returns zero (yes) or non-zero (no).

### Cf-serverd ACL's

As your infrastructure grows you'll need more than the simple cf-serverd ACL's that masterfiles provides. EFL allows you to configure extra rules, by reading the file sys_workdir/inputs/efl_data/bundle_params/efl_server.json if it exists. The file looks like this:

```
[
   {
      "promisee" : "cfengine server",
      "class" : "am_policy_hub",
      "path" : "${sys.workdir}/masterfiles/",
      "admit" : [
         "172.16.100.254",
         "2001:0DB8::/32"
      ]
   },
   {
      "path" : "${sys.workdir}/modules/",
      "class" : "am_policy_hub",
      "promisee" : "cfengine server",
      "admit" : [
         "172.16.100.254",
         "2001:0DB8::/32"
      ]
   },
   {
      "path" : "${sys.workdir}/sitefiles/",
      "class" : "am_policy_server",
      "promisee" : "cfengine server",
      "admit" : [
         "172.16.100.254",
         "2001:0DB8::/32"
      ]
   },
   {
      "path" : "${sys.workdir}/delta_reporting",
      "class" : "any",
      "promisee" : "delta reporting",
      "admit" : [
         "${sys.policy_hub}"
      ]
   }
]
```

Cf-serverd will read this data and turn them into server ACL's.

## Using promise outcome classes

TODO

## Auditing promise outcomes

All of these promise outcomes and all hard and soft classes can be gathered to a central server for reporting. See [Delta Reporting](https://github.com/neilhwatson/delta_reporting) for more information.

## Support

Commercial support is available through the creator of EFL, [Neil H. Waton](http://watson-wilson.ca) 
