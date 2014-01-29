#!/bin/bash

# Written by Evan Tschuy
# v0.9.0
# tschuye@onid.oregonstate.edu
# 28 January 2014 

# Inventory.dat location
INVENTORY=/home/tschuy/Downloads/inventory.dat

# Inventory loading function
# Initializes arrays and loads columns from inventory.dat into arrays
function load_inventory {
	OUTPUT=()
	LOCATION=()
	PRICE=()

	while IFS=, read col1 col2 col3
	do
	        OUTPUT+=($col1)
	        LOCATION+=($col2)
	        PRICE+=($col3)
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

	# Write new row to inventory.dat and reload inventory
	echo "$NEW_NAME,$NEW_LOCATION,$NEW_PRICE" >> $INVENTORY
	printf "\nItem added!"
	load_inventory
}

function main {
	load_inventory
	while true; do
		clear

		printf "   ___  ____  _   _   ___ _____ _____ _____   ____  _                 \n  / _ \/ ___|| | | | |_ _| ____| ____| ____| / ___|| |_ ___  _ __ ___ \n | | | \___ \| | | |  | ||  _| |  _| |  _|   \___ \| __/ _ \| '__/ _ \ \n | |_| |___) | |_| |  | || |___| |___| |___   ___) | || (_) | | |  __/\n  \___/|____/ \___/  |___|_____|_____|_____| |____/ \__\___/|_|  \___|"                                                                      
		printf "\n\nWelcome to the unofficial OSU IEEE Store search program.\n\nOptions:\n   Enter Q to quit\n   Enter A to add to database\n   Enter R to refresh database\n\nOr, to search, enter partial part name: "
		read PART
		PART=${PART// /_}

		test "$PART" == "Q" && printf "\nGood bye!\n\n" && clear && break
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
					printf "%s: %s @ %s\n" "$ITEM_NAME" "$ITEM_LOCATION" "$ITEM_PRICE"
					COUNTER=1
				fi
			done
			PART_CLEAN=${PART//_/ }	
			test "$COUNTER" == "0" && printf "No results found for %s" "$PART_CLEAN"
	
			printf "\n"
		fi

		printf "\n"
		read -p "Press [Enter] key to continue..."
	done	
}

main
