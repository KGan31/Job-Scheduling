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
in_rq=()
count=0
beg=0
cur_time=0
min=0
sum_waiting_time=0
sum_turnaround_time=0
tq=0
p_time=0
gc=0
echo "Enter number of processes: "
read number
echo "Enter Time Quantum: "
read tq
for ((i = 0; i<$number; i++)) 
do
    echo "Process $((i+1)): "
    process[$i]=$(($i+1))
    read arrival_time[$i] burst_time[$i] priority[$i] 
    rem_time[$i]=${burst_time[$i]}
    in_rq[$i]=0
done

sort(){
    local m=0
    local n=0
    echo -e "\n"
    if [ $p_time -lt $tq ] && [ ${rem_time[$min]} -gt 0 ]
    then
        rem_time[$min]=$((rem_time[$min]-1))
        p_time=$((p_time+1))
        cur_time=$((cur_time+1))
        in_rq[$min]=1
        gannt_chart[$gc]=${process[$min]}
        echo "gc: ${gannt_chart[$gc]}"
        gc=$((gc+1))
    elif [ ${rem_time[$min]} -gt 0 ]
    then
        #cur_time=$((cur_time+rem_time[ $min ]))
        readyqueue[$count]=$min
        #rem_time[$min]=0
        in_rq[$min]=1
        count=$((count+1))
        p_time=0
        beg=$((beg+1))  
    fi
    

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
            if [ $cur_time -ge ${arrival_time[$i]} ] && [ ${rem_time[$i]} -gt 0 ] && [ ${in_rq[$i]} -eq 0 ]
            then
                readyqueue[$count]=$i
                count=$((count+1))
                in_rq[$i]=1
            elif [ ${rem_time[$i]} -eq 0 ]
            then
                completion_time[$i]=$cur_time
                turnaround_time[$i]=$((completion_time[$i]-arrival_time[$i]))
                sum_waiting_time=$((sum_waiting_time+waiting_time[$i]))
                sum_turnaround_time=$((sum_turnaround_time+turnaround_time[$i]))
                rem_time[$i]=-1
                in_rq[$i]=0
                beg=$((beg+1))
                p_time=0
            fi
        done
        min=${readyqueue[$beg]}
        echo "min: $min"
        echo "cur: $cur_time"
        flag1=0
        for ((i=0 ;i<$gc; i++))
        do
            if [ ${gannt_chart[$i]} -eq ${process[$min]} ]
            then
                flag1=1
            fi
        done
        if [ $flag1 -eq 0 ]
        then
            echo -e "arrival time: ${arrival_time[$min]} process: ${process[$min]} $cur_time"
            waiting_time[$min]=$((cur_time-arrival_time[$min]))
        fi
        sort
    done

    for ((i = 0; i<$gc; i++))
    do
        echo -n "${gannt_chart[$i]}"  
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