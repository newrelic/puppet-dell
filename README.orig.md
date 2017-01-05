#puppet-dell

####Table of Contents

1. [Overview](#overview)
2. [Description ](#module-description)
3. [Setup](#setup)
    * [What puppet-dell affects](#what-puppet-dell-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet-dell](#beginning-with-puppet-dell)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
7. [Wanted](#wanted)

##Overview

Management for iDRAC cards on redhat dell systems using a custom provider and type.

##Module Description

This lets you enforce uniform configuration of iDRAC card settings including networking, users and passwords, and any other setting exposed by racadm. It does this using the running agent inside the operating system, not as a proxy, so it does not update systems that do not themselves run the puppet agent. 

##Setup

###What puppet-dell affects

* Settings on the system drac card
* Packages and repositiories in the host OS are added via classes.
* Some custom facts are added to expose the various iDRAC versions

###Setup Requirements

Obviously this only works on Dell hardware, and you need a working racadm install.
  
###Beginning with puppet-dell

The simplest thing to do is `include dell`, which will add all the packages and repositories necessary to run the custom types.

If that's too much, apply at least the dell::openmanage class to get the ipmi and racadm packages installed. 

After that you may declare drac_setting resources as you see fit.

##Usage

The drac_setting type takes a specially-formatted title to identify the card setting, and an `object_value` argument for the setting's value.

     drac_setting { 'cfgLanNetworking/cfgNicEnable':
        object_value => 1,
      }

The title uses a forward slash to separate components of the setting identifier. The format is like:

     Group/<index/>Object

This ensures that no setting is specified twice in one catalog. 

There are two styles of setting titles, as the racadm API changed around version 7. Here's the `cfgNicEnable` setting in iDRAC 7 style:

      drac_setting { 'iDRAC.NIC/Enable':
        object_value => 'Enabled',
      }


Some settings take an optional index element in the title, here is an example in iDRAC 6 style:

      drac_setting { 'cfgIpmiPet/1/cfgIpmiPetAlertDestIpAddr':
        object_value  => '192.168.0.50',
      }

This sets the first SNMP trap destination IP address (you may have up to 4). Here it is in iDRAC 7:

      drac_setting { 'iDRAC.SNMP.Alert/1/DestAddr':
        object_value  => '192.168.0.50',
      }

If you can use the iDRAC 7 style on your systems you should certainly do so, it is much clearer and allows access to more settings than the 6 syntax. If you have both styles of systems around you can select between them using the following pattern:

      if(use_drac7_syntax()) {
        drac_setting { 'iDRAC.NIC/Enable':
          object_value => 'Enabled',
        }
      else {
        drac_setting { 'cfgLanNetworking/cfgNicEnable':
          object_value => 1,
        }
      }

`use_drac7_syntax()` is a custom parser function this module adds to make this selection simple. It relies on two facts also added by this module, `idrac_firmware_version` and `idrac_major_version`. 

At the time of writing, cards that supported iDRAC 7 syntax continue to support the 6 style in a deprecated fashion, so if you wish to, you may avoid all this. Be aware that on these cards, most settings are exposed in both syntaxes, and this module will not stop you from enforcing two values on the same underlying setting by using both.

##Limitations

* This obviously isn't useful on machines that are powered off, so it is of limited use during hardware provisioning.
* `racadm` only allows a single instance of itself to run at a time, so sometimes puppet runs fail if `racadm` gets in a stuck state or MCollective is updating facts at the same time. The underlying provider returns a useful message, but we can't assert anything about the state of the resource so it simply fails. 
* You have to specify 6- and 7-style configuration values separately in your manifests. 
* Some settings have dependencies not enforced by the type, notably the management NIC which disallows enabling of its DHCP DNS servers unless DHCP is enabled on the card. You can work around it by adding resource dependencies like so:

```
      drac_setting { 'cfgLanNetworking/cfgNicUseDhcp':
        object_value => 1,
      }
      
      drac_setting { 'cfgLanNetworking/cfgDNSServersFromDHCP':
        object_value => 1,
        require      => Drac_setting['cfgLanNetworking/cfgNicUseDhcp'];
      }
```

but these dependencies will have to be discovered experimentally as the type does not handle configuration objects on an individual basis.

##Development

Fork, work in topic branch, test changes, make pull request. 

##Wanted

* Tests for the types, providers and facts
* Support more operating systems.
* `puppet device` style management of powered-off hardware.
* Paper over the 6/7 style syntax split and use a translation layer.
