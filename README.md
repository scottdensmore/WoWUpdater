#WoWUpdater#
A ruby client to update addons for World of Warcraft. 

##Background##
A while back myself and Peter Provost wrote this updater to update our WoW addon directories for the game. We needed it to work on multiple platforms (Mac / Windows) and with multiple addon sites. We decided to use a yaml file to download the addons.

##Configuration File###
The yaml file is used to list each addon from the site you want to download.

##Usage##
* ruby WoWUpdater.rb 

	This will update your addons based on the configuration file from the default World of Warcraft installation directory.
	
	* Parameters
	
		wowpath - The alternative path to your World of Warcraft installation
		






## Continuous integration

Offline checks parse every Ruby file and run nine synthetic regression cases for local version records, independent addon dependency lists and both XML listeners. Each case owns a newly generated temporary directory; the suite never loads the updater, download helper, ZIP helper or configured addon list. It uses preinstalled Ruby/REXML without installing tools or gems.

This validates the model/parser subset only. Updater startup, the legacy `rdoc/usage` and `zip/zipfilesystem` dependencies, provider/network compatibility, downloads and extraction are not validated. CI never accesses game directories or real addon services, uses API credentials, or updates installed addons. Application source and user configuration remain unchanged.
