### Requirements

* Cfengine 3.5.1+
* The Evolve free promise library (see below).
* A good understanding of Cfengine 3.

### Warning
Turning all of these policies on may result in loss of expected service. Test
carefully to understand how hardening will affect your hosts.

### Install
1. Copy contents of masterfiles to your masterfiles.
1. Install the Evolve free promise library to your masterfiles.
https://github.com/evolvethinking/evolve_cfengine_freelib
1. Include the library in Cfengine's inputs directive in promises.cf.
1. Call the efl_main bundle where appropriate in your existing policy. The best
approach is to call it using a methods.

```
methods:
   "Evolve Thinking Delta Hardening"
      usebundle => efl_main( "/var/cfengine/inputs/delta_methods.json" );
```

### Reporting

For auditing consider [Delta Reporting](https://github.com/evolvethinking/delta_reporting).

Copyright Evolve Thinking ( www.evolvethinking.com ).
