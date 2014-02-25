#!/bin/bash

# Written by Evan Tschuy
# v0.9.5
# tschuye@onid.oregonstate.edu
# 25 February 2014 

# data files location
INVENTORY=/home/tschuy/Downloads/inventory.dat
USAGE=/home/tschuy/Downloads/.usage.dat

# Inventory loading function
# Initializes arrays and loads columns from inventory.dat into arrays
function load_inventory {
	date +"%c" >> $USAGE	
	echo " Inventory reloaded" >> $USAGE
	OUTPUT=()
	LOCATION=()
	PRICE=()
	PLU=()

	while IFS=, read col1 col2 col3 col4
	do
	        OUTPUT+=($col1)
	        LOCATION+=($col2)
	        PRICE+=($col3)
			PLU+=($col4)
	done < $INVENTORY
} 

# Adds new item to inventory.dat
function add_to_inventory {
	printf "\nEnter item name: "
	read NEW_NAME
	NEW_NAME=${NEW_NAME// /_} # Sanitize input (replace space with _)
	printf "Enter item location: "
	read NEW_LOCATION
	NEW_LOCATION=${NEW_LOCATION// /_}
	printf "Enter item price: "
	read NEW_PRICE
	NEW_PRICE=${NEW_PRICE// /_}
	printf "Enter item PLU: "
	read NEW_PLU
	NEW_PLU=${NEW_PLU// /_}

	# Write new row to inventory.dat and reload inventory
	echo "$NEW_NAME,$NEW_LOCATION,$NEW_PRICE,$NEW_PLU" >> $INVENTORY
	date +"%c" >> $USAGE
	echo " User added new inventory item \"$NEW_NAME\"" >> $USAGE
	printf "\nItem added!"
	load_inventory
}

function main {
	load_inventory
	while true; do
		clear

		printf "   ___  ____  _   _   ___ _____ _____ _____   ____  _                 \n  / _ \/ ___|| | | | |_ _| ____| ____| ____| / ___|| |_ ___  _ __ ___ \n | | | \___ \| | | |  | ||  _| |  _| |  _|   \___ \| __/ _ \| '__/ _ \ \n | |_| |___) | |_| |  | || |___| |___| |___   ___) | || (_) | | |  __/\n  \___/|____/ \___/  |___|_____|_____|_____| |____/ \__\___/|_|  \___|"                                                                      
		printf "\n\nWelcome to the unofficial OSU IEEE Store search program.\nFound an item listed as unknown? Need to report a bug?\nEmail the author! tschuye@onid.oregonstate.edu\n\nOptions:\n   Enter Q to quit\n   Enter A to add to database\n   Enter R to refresh database\n\nOr, to search, enter partial part name: "
		read PART
		PART=${PART// /_}

		test "$PART" == "Q" && date +"%c" >> $USAGE && echo " User quit" >> $USAGE && printf "\nGood bye!\n\n" && clear && break
		test "$PART" == "A" && add_to_inventory
		test "$PART" == "R" && load_inventory && printf "\nInventory reloaded.\n\n"
		printf "\n"
		COUNTER=0
		if [[ "$PART" != "A" && "$PART" != "Q" && "$PART" != "R" ]] ; then
			for item in ${!OUTPUT[*]}
			do
				if echo "${OUTPUT[item],,}" | egrep -q "${PART,,}" ; then # Check if item in array OUTPUT contains in part the user-specified part
					ITEM_NAME=${OUTPUT[$item]//_/ } # Replace underscores with spaces (slightly hacky)
					ITEM_LOCATION=${LOCATION[$item]//_/ } # Same here
					ITEM_PRICE=${PRICE[$item]//_/ } # And here
					ITEM_PLU=${PLU[$item]//_/ } # lastly here
					printf "%s (PLU %s): %s @ %s\n" "$ITEM_NAME" "$ITEM_PLU" "$ITEM_LOCATION" "$ITEM_PRICE"
					COUNTER=1
				fi
			done
			PART_CLEAN=${PART//_/ }	
			test "$COUNTER" == "0" && printf "No results found for %s" "$PART_CLEAN"
			printf "\n"
		fi
		date +"%c" >> $USAGE && printf " User searched for %s""$PART_CLEAN" >> $USAGE && echo >> $USAGE

		printf "\n"
		read -p "Press [Enter] key to continue..."
	done	
}

main
