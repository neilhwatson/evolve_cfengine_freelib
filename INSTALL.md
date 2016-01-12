## Installation using autorun

1. Copy the contents of masterfiles into your masterfiles or equivalent repository.
1. Enable autorun, if you have not do so already, by adding this class to your ```def.json``` file.
```
{
   "classes" :
   {
      "services_autorun" : "any"
   }
}
```

This setup will run the bundle efl_main with the data file ```masterfiles/efl_data/bundle_params/efl_main.json```, a file that you create.

Next, build your data files to feed the bundles. Typically store the data files in ```masterfiles/efl_data```.

## Building data files

Here's a trivial example to get you started. First create a data file to define classes using the classmatch function. Note that EFL does not create the efl_data subdirectory. You must do it.
```
vim masterfiles/efl_data/classes/efl_classmatch.json
[
   {
      "class_to_set" : "my_dmz_hosts",
      "regex"        : "ipv4_10_0_[2,3,4]_\d+",
      "promisee"     : "dmz security"
   }
]
```

Then a command promise.
```
vim masterfiles/efl_data/bundle_params/efl_command.json
[
   {
      "class" : "my_dmz_hosts",
      "command" : "/usr/local/sbin/encrypt_backup.sh",
      "useshell" : "noshell",
      "module" : "no",
      "ifelapsed" : "1440",
      "promisee" : "dmz security"
   }
]
```

Call both via the efl_main bundle.
```
vim mastefiles/efl_data/bundle_params/efl_main.json
[
   {
      "class" : "any"
      "promiser" : "set classes",
      "bundle" : "efl_class_classmatch",
      "ifelapsed" : "1",
      "parameter" : "${sys.inputdir}/efl_data/bundle_params/efl_classmatch.json",
      "promisee" : "cfengine policy"
   },
   {
      "class" : "any",
      "promiser" : "running commands",
      "bundle" : "efl_command",
      "ifelapsed" : "1",
      "parameter" : "${sys.inputdir}/efl_data/bundle_params/efl_command.json",
      "promisee" : "cfengine policy"
   }
]
```

Once you deploy this to masterfiles your agents will pick them up and run EFL.

