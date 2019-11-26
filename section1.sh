#!/bin/bash

#Nicholas Schroeder	[NIS102]
#  ECE 1160 - LAB4	[SECTION 1]
#  DUE 11-20-2019

echo -ne "LAB 4 -- SECTION 1\n"

USERNAME=$(whoami)
ROOTNAME="root"

CPU_INFO_DIR=/sys/devices/system/cpu
CURR_FREQ_PATH=/cpufreq/cpuinfo_cur_freq
MAX_FREQ_PATH=/cpufreq/cpuinfo_max_freq
MIN_FREQ_PATH=/cpufreq/cpuinfo_min_freq
SCALING_GOV_PATH=/cpufreq/scaling_governor
AVAIL_GOV_PATH=/cpufreq/scaling_available_governors
AVAIL_FREQ_PATH=/cpufreq/scaling_available_frequencies
SET_FREQ=/cpufreq/scaling_setspeed

WORK=/home/pi/COE_1160/lab4/work

#-----------------------FUNCTIONS---------------------------------#

function section1_1 {
	echo -ne "Navigating to $CPU_INFO_DIR\n"
	cd $CPU_INFO_DIR

	echo

	CPU_COUNT=0

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				CURR_FREQ=$(cat ./$ENTRY/$CURR_FREQ_PATH)
				MAX_FREQ=$(cat ./$ENTRY/$MAX_FREQ_PATH)
				MIN_FREQ=$(cat ./$ENTRY/$MIN_FREQ_PATH)
				AVAIL_FREQ=$(cat ./$ENTRY/$AVAIL_FREQ_PATH)

				echo -ne "CPU $CPU_COUNT\n"
				echo -ne "  Current Frequency: $CURR_FREQ\n"
				echo -ne "  Maximum Frequency: $MAX_FREQ\n"
				echo -ne "  Minimum Frequency: $MIN_FREQ\n"
				echo -ne "  Available Frequencies: $AVAIL_FREQ\n"

				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	echo
	echo -ne "CPUs: $CPU_COUNT\n"
	echo $(lscpu | grep "Thread")
	echo $(lscpu | grep "Core(s)")
	echo $(lscpu | grep "Socket")
}

function section1_2 {
	echo -ne "Navigating to $CPU_INFO_DIR\n"
	cd $CPU_INFO_DIR

	echo

	CPU_COUNT=0

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				SCALING_GOVERNOR=$(cat ./$ENTRY/$SCALING_GOV_PATH)
				AVAIL_GOVS=$(cat ./$ENTRY/$AVAIL_GOV_PATH)

				echo -ne "CPU $CPU_COUNT\n"
				echo -ne "  Scaling Governor: $SCALING_GOVERNOR\n"
				echo -ne "  Available Governors: $AVAIL_GOVS\n"

				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	echo

	for GOV in $AVAIL_GOVS
	do
		echo -ne "Setting scaling governor to: $GOV\n"

		for ENTRY in *
		do
			if [[ $ENTRY == cpu[0-9] ]]
				then
					sudo echo $GOV | sudo dd status=none of=./$ENTRY/$SCALING_GOV_PATH
			fi
		done

		CPU_COUNT=0

		echo -ne "\nSTARTING WORK...\n"
		$WORK &
		sleep 1

		for ENTRY in *
		do
			if [[ $ENTRY == cpu[0-9] ]]
				then
					CURR_FREQ=$(cat ./$ENTRY/$CURR_FREQ_PATH)

					echo -ne "CPU $CPU_COUNT: Current Frequency = $CURR_FREQ\n"

					CPU_COUNT=$((CPU_COUNT + 1))
			fi
		done

		wait

		echo
	done
}

function section1_3 {
	echo -ne "Navigating to $CPU_INFO_DIR\n"
	cd $CPU_INFO_DIR

	echo -ne "Setting CPU frequency to MAX\n"

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				sudo echo userspace | sudo dd status=none of=./$ENTRY/$SCALING_GOV_PATH
				MAX_FREQ=$(cat ./$ENTRY/$MAX_FREQ_PATH)

				echo $MAX_FREQ | sudo dd status=none of=./$ENTRY/$SET_FREQ
		fi
	done

	CPU_COUNT=0

	echo -ne "\nSTARTING WORK...\n"
	$WORK &
	sleep 1

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				CURR_FREQ=$(cat ./$ENTRY/$CURR_FREQ_PATH)

				echo -ne "CPU $CPU_COUNT: Current Frequency = $CURR_FREQ\n"

				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	wait

	echo
	echo -ne "Setting CPU frequency to MIN\n"

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				MIN_FREQ=$(cat ./$ENTRY/$MIN_FREQ_PATH)

				echo $MIN_FREQ | sudo dd status=none of=./$ENTRY/$SET_FREQ
		fi
	done

	CPU_COUNT=0

	echo -ne "\nSTARTING WORK...\n"
	$WORK &
	sleep 1

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				CURR_FREQ=$(cat ./$ENTRY/$CURR_FREQ_PATH)

				echo -ne "CPU $CPU_COUNT: Current Frequency = $CURR_FREQ\n"

				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	wait
}

function get_selection {
	NOT_SELECTED=true

	while $NOT_SELECTED
	do
		echo
		echo -ne "Options:\n"
		echo -ne "  Section 1.1\t[1]\n"
		echo -ne "  Section 1.2\t[2]\n"
		echo -ne "  Section 1.3-4\t[3]\n"
		echo -ne "  Quit\t\t[4]\n"

		read -p "Make a selection [1,2,3, or 4]: " SELECTION

		if (($SELECTION >= 1 && $SELECTION <= 4))
			then
				NOT_SELECTED=false
		fi
	done
}

#-----------------------------------------------------------------------------#

if [[ $USERNAME != $ROOTNAME ]]
	then
		echo -ne "You must run this program as root.\n"
		echo -ne "Exiting...\n"

		exit;
fi

while true
do
	get_selection
	echo

	case $SELECTION in
		1)
			echo -ne "Executing Section 1.1\n"
			section1_1;;
		2)
			echo -ne "Executing Section 1.2\n"
			section1_2;;
		3)
			echo -ne "Executing Section 1.3 and 1.4\n"
			section1_3;;
		4)
			echo -ne "Exiting...\n"
			exit;;
		*)
			echo -ne "Invalid user input detected.\n"
			echo -ne "Exiting...\n"

			exit;;
	esac
done

