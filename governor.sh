#!/bin/bash

#Nicholas Schroeder	[NIS102]
#  ECE 1160 - LAB4	[GOVERNOR]
#  DUE 11-20-2019

echo -ne "LAB 4 - CPU FREQUENCY GOVERNOR\n\n"

USERNAME=$(whoami)
ROOTNAME="root"

CPU_INFO_DIR=/sys/devices/system/cpu
CURR_FREQ_PATH=/cpufreq/cpuinfo_cur_freq
SCALING_GOV_PATH=/cpufreq/scaling_governor
MAX_FREQ_PATH=/cpufreq/cpuinfo_max_freq
MIN_FREQ_PATH=/cpufreq/cpuinfo_min_freq
SET_FREQ=/cpufreq/scaling_setspeed

RECORD=/home/pi/COE_1160/lab4/record
NEW_RECORD=/home/pi/COE_1160/lab4/new_record

#-----------------------FUNCTIONS---------------------------------#

function set_userspace {
	echo -ne "Changing governor to userspace...\n"

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				sudo echo userspace | sudo dd status=none of=./$ENTRY/$SCALING_GOV_PATH
		fi
	done

	echo -ne "Successfully set scaling governor to userspace.\n\n"
}

function get_freq {
	FREQ_SUM=0
	CPU_COUNT=0

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				CPU_FREQ=$(cat ./$ENTRY/$CURR_FREQ_PATH)
				FREQ_SUM=$((FREQ_SUM + CPU_FREQ))

				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	AVG_FREQ=$((FREQ_SUM / CPU_COUNT))
}

function get_max_util {
	CPU_COUNT=0
 
	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	MAX_UTIL=0

	for (( i = 0 ; i < $CPU_COUNT ; i++)) 
	do
		PREV_IDLE=$(cat $RECORD | grep "cpu$i" | awk '{prev_idle=($5 + $6)} END {print prev_idle}')
		CURR_IDLE=$(cat $NEW_RECORD | grep "cpu$i" | awk '{i=($5 + $6)} END {print i}')
		
		PREV_BUSY=$(cat $RECORD | grep "cpu$i" | awk '{pb=($2 + $3 + $4 + $7 + $8)} END {print pb}')
		CURR_BUSY=$(cat $NEW_RECORD | grep "cpu$i" | awk '{pb=($2 + $3 + $4 + $7 + $8)} END {print pb}')

		PREV_TOTAL=$((PREV_IDLE + PREV_BUSY))
		CURR_TOTAL=$((CURR_IDLE + CURR_BUSY))

		TOTAL_DIFF=$((CURR_TOTAL - PREV_TOTAL))
		IDLE_DIFF=$((CURR_IDLE - PREV_IDLE))

		CURR_UTIL=$(awk "BEGIN{print int(100*($TOTAL_DIFF - $IDLE_DIFF ) / $TOTAL_DIFF)}")
		
		if (( $CURR_UTIL > $MAX_UTIL ))
			then
				MAX_UTIL=$CURR_UTIL
		fi
	done

	UTIL=$MAX_UTIL
}

function set_freq {
	NEW_FREQ=$1

	MIN_FREQ=$(cat $CPU_INFO_DIR/cpu0/$MIN_FREQ_PATH)
	MAX_FREQ=$(cat $CPU_INFO_DIR/cpu0/$MAX_FREQ_PATH)

	echo -ne "Calculated Next Frequency = $NEW_FREQ\n"

	if (( $NEW_FREQ <= 900000))
		then
			NEW_FREQ=$MIN_FREQ
	elif (( $NEW_FREQ > 900000 ))
		then
			NEW_FREQ=$MAX_FREQ
	fi

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				sudo echo $NEW_FREQ | sudo dd status=none of=./$ENTRY/$SET_FREQ
		fi
	done
}

function set_record {
	rm -rf $RECORD
	touch $RECORD

	CPU_COUNT=0

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	for (( i = 0 ; i < $CPU_COUNT ; i++)) 
	do
		PREV_RECORD=$(cat /proc/stat | grep "cpu$i")
		echo $PREV_RECORD >> $RECORD
	done
}

function set_new_record {
	rm -rf $NEW_RECORD
	touch $NEW_RECORD

	CPU_COUNT=0

	for ENTRY in *
	do
		if [[ $ENTRY == cpu[0-9] ]]
			then
				CPU_COUNT=$((CPU_COUNT + 1))
		fi
	done

	for (( i = 0 ; i < $CPU_COUNT ; i++)) 
	do
		PREV_RECORD=$(cat /proc/stat | grep "cpu$i")
		echo $PREV_RECORD >> $NEW_RECORD
	done
}

#----------------------------------------------------------------------------#
#--------------------------------MAIN-----------------------------------#

if [[ $USERNAME != $ROOTNAME ]]
	then
		echo -ne "Program must be run as root.\n"
		echo -ne "Exiting...\n"

		exit;
fi

echo -ne "Navigating to $CPU_INFO_DIR\n"
cd $CPU_INFO_DIR

echo

set_userspace
set_record
set_new_record

while true
do
	get_freq
	get_max_util

	set_new_record

	MAX_FREQ=$(cat $CPU_INFO_DIR/cpu0/$MAX_FREQ_PATH)

	echo -ne "\nCurrent Frequency: $AVG_FREQ\n"
	echo -ne "Current CPU Utilization: $UTIL%\n"

	NEXT_FREQ=$( awk "BEGIN{print int(1.25*$MAX_FREQ*$UTIL/100)}" )
	set_freq $NEXT_FREQ

	set_record
	sleep 0.5
done

#----------------------------------------------------------------------------#

