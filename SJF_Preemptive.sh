arrival_time=("@")
burst_time=("@")
priority=("@")
process=()
rem_time=()
completion_time=()
waiting_time=()
turnaround_time=()
readyqueue=()
gannt_chart=()
count=0
beg=0
cur_time=0
min=0
sum_waiting_time=0
sum_turnaround_time=0
echo "Enter number of processes: "
read number
for((i = 0; i<$number; i++)) 
do
    echo "Process $((i+1)): "
    process[$i]=$(($i+1))
    read arrival_time[$i] burst_time[$i] priority[$i] 
    rem_time[$i]=${burst_time[$i]}
done

sort(){
    local m=0
    local n=0
    min=${readyqueue[0]}
    echo -e "\n"
    for ((m=0; m<$count; m++))
    do
        if [ ${rem_time[ ${min}]} -gt ${rem_time[ ${readyqueue[$m]} ]} ]
        then
            min=${readyqueue[$m]}
            n=$m
        fi
    done

    for ((t = 0; t<$number; t++))
    do
        echo "${process[ $t ]} ${rem_time[ $t ]}"
    done

    echo -e "\n"
}

SJF_scheduling(){
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

                p=${rem_time[$j]}
                rem_time[ $j ]=${rem_time[ $k]}
                rem_time[ $k ]=$p

            elif [ ${arrival_time[ $k ]} -eq $t ] && [ ${priority[ $k ]} -lt ${priority[ $i ]} ]
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

                p=${rem_time[$j]}
                rem_time[ $j ]=${rem_time[ $k]}
                rem_time[ $k ]=$p
            fi
        done
    done
    flag=0
    while [ $flag -ne 1 ]
    do
        flag=1
        for ((i = 0; i<$number; i++))
        do
            if [ ${rem_time[$i]} -gt 0 ]
            then
                flag=0
            fi
        done
        for ((i=0; i<$number; i++))
        do
            if [ $cur_time -ge ${arrival_time[$i]} ] && [ ${rem_time[$i]} -gt 0 ]
            then
                readyqueue[$count]=$i
                count=$((count+1))
            elif [ ${rem_time[$i]} -eq 0 ]
            then
                completion_time[$i]=$((cur_time))
                turnaround_time[$i]=$((completion_time[$i]-arrival_time[$i]))
                sum_waiting_time=$((sum_waiting_time+waiting_time[$i]))
                sum_turnaround_time=$((sum_turnaround_time+turnaround_time[$i]))
                rem_time[$i]=-1
            fi
        done
        sort
        flag1=0
        for ((i=0 ;i<$cur_time; i++))
        do
            if [ ${gannt_chart[$i]} -eq ${process[$min]} ]
            then
                flag1=1
            fi
        done
        if [ $flag1 -eq 0 ]
        then
            waiting_time[$min]=$((cur_time-arrival_time[$min]))
        fi
        gannt_chart[$cur_time]=${process[$min]}
        cur_time=$((cur_time+1))
        rem_time[$min]=$((rem_time[$min]-1))
        count=0
    done

    for ((i = 0; i<$cur_time; i++))
    do
        echo -n "${gannt_chart[$i]} "  
    done

    avg_waiting_time=$(echo "scale=2; $sum_waiting_time/$number" | bc -l)
    avg_turnaround_time=$(echo "scale=2; $sum_turnaround_time/$number" | bc -l)
    echo -e "\nProcesses\tArrival Time\tBurst Time\tPriority\tCompletion Time\tWaiting Time\tTurnaround Time"
    for ((i = 0; i<number; i++))
    do
        echo -e "${process[$i]} \t\t ${arrival_time[$i]} \t\t ${burst_time[$i]} \t\t ${priority[$i]} \t\t${completion_time[$i]} \t\t ${waiting_time[$i]} \t\t ${turnaround_time[$i]}"  
    done
    echo -e "Average waiting time: $avg_waiting_time \nAverage Turnaround Time: $avg_turnaround_time"
}

SJF_scheduling