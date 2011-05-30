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
		




