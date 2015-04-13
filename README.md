Copyright Evolve Thinking ( www.evolvethinking.com ).
For fresh updates visit:
https://github.com/evolvethinking/evolve_cfengine_freelib

## License

Evolve_freelib.cf is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

## 3.6.3+ ready!

This master branch is ready for 3.6.3+. Most bundles now support both CSV and JSON
parameter files. A conversion script is included in ./bin.

## Upgrade from 3.5?

1. Template source in efl_edit_templates and efl_service must now have an
   extention to identify them as cfengine (tmp|template) or mustache
   (mus|mustache) style templates.
1. Efl_edit_templates now has a server column that works just like efl_service
   and other bundles. Add the column between the source file and mode.

## Introduction

The bundles contained in this CFEngine library primarily focus on data driven
policy.  Each such bundle takes csv of JSON type delimited parameter file as shown in
the common bundle efl_c.

### Contents of the main library
| Bundle | Purpose |
|--------|---------|
| efl_skeleton | A template for creating new bundles. |
| efl_c | A collection of common tunable variables. |
| efl_main | A bundle for calling other bundles, in order, using methods. |
| efl_chkconfig_disable_service | Disable a service from starting at boot. |
| efl_chkconfig_enable_service | Enable a service to start at boot. |
| efl_class_classmatch | Creates namespace classes by matching existing class names. |
| efl_class_cmd_regcmp | Creates namespace classes on the output of a shell command. |
| efl_class_expression | Creates namespace classes from a class expression. |
| efl_class_hostname | Creates namespace classs based on the hostname of the host. |
| efl_class_iprange | Creates namespace classes based on the IP address of the host. |
| efl_class_returnszero | Creates namespace classes using the return status of a shell command. |
| efl_command | Configurable commands promises. |
| efl_copy_files | Configurable file copy promises. |
| efl_delete_files | Promises to delete files. |
| efl_edit_template | Promise a file's contents using a template. |
| efl_file_perms | Configurable file permissions promises. |
| efl_global_slists | Set namespace scoped slists variables. |
| efl_global_strings | Set namespace scoped strings variables. |
| efl_lastseen | Report hosts seen in the last 24 hours. |
| efl_link | Promise links. |
| efl_mon_cfengine | Report CFEngine internal statistics. |
| efl_notseen | Report hosts not seen in the last 24 hours. |
| efl_packages | Promises to add, remove, or update packages. |
| efl_rcs_pull | Promises to keep a checked out copy of version control current. |
| efl_server | Promise server access rules. |
| efl_service | Promises to configure and start a service. |
| efl_start_service | Promises to start a service that is not running. |
| efl_sysctl_conf_file | Promises sysctl.conf kernel settings. |
| efl_sysctl_live | Promises live sysctl Linux kernel settings. |

### An alternate inputs update file

The file efl_update.cf is an alternate high performance, yet simplified,
collection of bundles to keep CFEngine's inputs directory up to date. See the
in docs for more information.

## Requirements

1. Cfengine Core 3.6.3 or higher. There are older 3.4, and 3.5 branch too.
1. The Cfengine standard library. 
1. Perl of any version and no special modules.

## Futher reading

1. [INSTALL.md](INSTALL.md)
1. [HOWTO.md](HOWTO.md)
1. EFL related articles: http://evolvethinking.com/category/cfengine/efl/

## Reporting

If you are interested in reporting on the outcome of EFL promises please look at Delta Reporting:
https://github.com/evolvethinking/delta_reporting
