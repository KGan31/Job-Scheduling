arrival_time=("@")
burst_time=("@")
priority=("@")
process=()
completion_time=()
waiting_time=()
turnaround_time=()
readyqueue=()
count=0
beg=1
echo "Enter number of processes: "
read number
for((i = 0; i<$number; i++)) 
do
    echo "Process $((i+1)): "
    process[$i]=$(($i+1))
    read arrival_time[$i] burst_time[$i] priority[$i] 
done

sort(){
    local m=$beg
    local n=0
    local max=${readyqueue[0]}
    echo -e "\n"
    for ((m=0; m<$count; m++))
    do
        if [ ${priority[ ${max}]} -lt ${priority[ ${readyqueue[$m]} ]} ]
        then
            max=${readyqueue[$m]}
            n=$m
        fi
    done

    p=${arrival_time[$max]}
    arrival_time[$max]=${arrival_time[$beg]}
    arrival_time[$beg]=$p

    p=${burst_time[$max]}
    burst_time[$max]=${burst_time[$beg]}
    burst_time[$beg]=$p

    p=${priority[$max]}
    priority[$max]=${priority[$beg]}
    priority[$beg]=$p

    p=${process[$max]}
    process[$max]=${process[$beg]}
    process[$beg]=$p
    for ((t = 0; t<$number; t++))
    do
        echo "${process[ $t ]} ${priority[ $t ]}"
    done

    echo -e "\n"
}

priority_scheduling(){
    local i=0
    local j=0
    for ((i = 0; i<$number; i++))
    do
        t=${arrival_time[ $i]}
        for ((j=$i; j>0; j--))
        do
            k=$j-1
            if [ ${arrival_time[ $k ]} -gt $t ]
            then
                p=${arrival_time[ $j ]}
                arrival_time[ $j ]=${arrival_time[ $k]}
                arrival_time[ $k ]=$p

                p=${burst_time[ $j ]}
                burst_time[ $j ]=${burst_time[ $k]}
                burst_time[ $k ]=$p

                p=${priority[ $j ]}
                priority[ $j ]=${priority[ $k]}
                priority[ $k ]=$p

                p=${process[ $j ]}
                process[ $j ]=${process[ $k]}
                process[ $k ]=$p
            fi
        done
    done

    completion_time[0]=$((arrival_time[0]+burst_time[0]))
    waiting_time[0]=0
    turnaround_time[0]=$((arrival_time[0]+burst_time[0]))
    sum_waiting_time=0
    sum_turnaround_time=$((arrival_time[0]+burst_time[0]))
    for ((i = 1; i<$number; i++))
    do
        for ((j = $i; j<$number; j++))
        do 
        if [ ${completion_time[$i-1]} -ge ${arrival_time[$j]} ]
            then
                readyqueue[$count]=$j
                count=$((count+1))
                echo "${process[$j]}"
            else
                break
            fi
        done
        sort
        if [ ${completion_time[$i-1]} -ge ${arrival_time[$i]}  ]
        then
            completion_time[$i]=$((completion_time[$i-1]+burst_time[$i]))
        else
            completion_time[$i]=$((arrival_time[$i]+burst_time[$i]))
        fi
        waiting_time[$i]=$((completion_time[$i]-arrival_time[$i]-burst_time[$i]))
        turnaround_time[$i]=$((completion_time[$i]-arrival_time[$i]))
        sum_waiting_time=$((sum_waiting_time+waiting_time[$i]))
        sum_turnaround_time=$((sum_turnaround_time+turnaround_time[$i]))
        beg=$((beg+1))
        count=0
    done
    avg_waiting_time=$(echo "scale=2; $sum_waiting_time/$number" | bc -l)
    avg_turnaround_time=$(echo "scale=2; $sum_turnaround_time/$number" | bc -l)
    echo -e "Processes\tArrival Time\tBurst Time\tPriority\tCompletion Time\tWaiting Time\tTurnaround Time\n"
    for ((i = 0; i<number; i++))
    do
        echo -e "${process[$i]} \t\t ${arrival_time[$i]} \t\t ${burst_time[$i]} \t\t ${priority[$i]} \t\t${completion_time[$i]} \t\t ${waiting_time[$i]} \t\t ${turnaround_time[$i]}"  
    done
    echo -e "Average waiting time: $avg_waiting_time \nAverage Turnaround Time: $avg_turnaround_time"
}

priority_scheduling