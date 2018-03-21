#!/bin/sh

#Settings
NUM_CARDS=1
NS="/usr/bin/nvidia-settings"

# Infinite loop
while :
do
    # Per cards loop
    i=0
    while [ $i -lt $NUM_CARDS ]
    do
        GPU_TEMP=`nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv,noheader`
        FAN_SPEED=`nvidia-smi -i $i --query-gpu=fan.speed --format=csv,noheader,nounits`

        #Default value for low temperature
        TARGET_FUN_SPEED=30 

        echo "GPU$i T=$GPU_TEMP and F=$FAN_SPEED"
        
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
sleep 5
done
