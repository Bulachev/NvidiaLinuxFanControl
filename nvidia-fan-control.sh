#!/bin/sh

#Settings
BASEDIR=$(dirname $0)
NUM_CARDS=`cat $BASEDIR/numcards.txt`
NS="/usr/bin/nvidia-settings"

# Help info
if [ "$1" = 'info' ]; then
    echo "Current mode is: only show info \r\n"

elif [ -z $1 ] || [ "$1" = 'control'  ]; then 
    echo "Current mode is: control fan speed \r\n"

else
    echo "Use 'info' or 'control' command."
    exit
fi

# Infinite loop
while :
do
    # Display date & time
    echo `date`

    # Per cards loop
    i=0
    while [ $i -lt $NUM_CARDS ]
    do
        GPU_TEMP=`nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv,noheader`
        FAN_SPEED=`nvidia-smi -i $i --query-gpu=fan.speed --format=csv,noheader,nounits`

        #Default value for low temperature
        TARGET_FUN_SPEED=30 

        echo "GPU$i T=$GPU_TEMP and F=$FAN_SPEED"
        
	# If just informate then it is all done
	if [ "$1" = 'info' ]; then
	    i=`expr $i + 1`
	    continue
	fi

        # Check temperature and decied target fan speed
        if ([ $GPU_TEMP -ge 50 ]) then
            if ([ $GPU_TEMP -ge 70 ]) then
                TARGET_FUN_SPEED=100
            else
                TARGET_FUN_SPEED=80
            fi
        fi

        # Set new fan speed if it is diffrenet from current
        if ([ $FAN_SPEED -ne $TARGET_FUN_SPEED ]) then 
            echo "Setting FunSpeed to $TARGET_FUN_SPEED"
            $NS -a [gpu:$i]/GPUFanControlState=1 -a [fan:$i]/GPUTargetFanSpeed=$TARGET_FUN_SPEED > /dev/null 2>&1
        fi
	
	i=`expr $i + 1`
    done
    echo "-----------------------\r\n"	
sleep 5
done
