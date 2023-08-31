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

input(){

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
}

sort_arrival_time(){
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
}

print_result(){
    echo -n "Gannt Chart: "
    for ((i = 0; i<$gc; i++))
    do
        echo -n "${gannt_chart[$i]} "  
    done

    avg_waiting_time=$(echo "scale=2; $sum_waiting_time/$number" | bc -l)
    avg_turnaround_time=$(echo "scale=2; $sum_turnaround_time/$number" | bc -l)
    echo -e "\nProcesses\tArrival Time\tBurst Time\tPriority\tCompletion Time\tWaiting Time\tTurnaround Time"
    for ((i = 0; i<$number; i++))
    do
        echo -e "${process[$i]} \t\t ${arrival_time[$i]} \t\t ${burst_time[$i]} \t\t ${priority[$i]} \t\t${completion_time[$i]} \t\t ${waiting_time[$i]} \t\t ${turnaround_time[$i]}"  
    done
    echo -e "Average waiting time: $avg_waiting_time \nAverage Turnaround Time: $avg_turnaround_time"
}


FCFS(){
    completion_time[0]=$((arrival_time[0]+burst_time[0]))
    waiting_time[0]=0
    turnaround_time[0]=$((arrival_time[0]+burst_time[0]))
    sum_waiting_time=0
    sum_turnaround_time=$((arrival_time[0]+burst_time[0]))
    gannt_chart[0]=${process[0]}
    for ((i = 1; i<$number; i++))
    do
        if [ ${completion_time[$i-1]} -gt ${arrival_time[$i]} ]
        then
            completion_time[$i]=$((completion_time[$i-1]+burst_time[$i]))
        else 
            completion_time[$i]=$((arrival_time[$i]+burst_time[$i]))
        fi
        waiting_time[$i]=$((completion_time[$i]-arrival_time[$i]-burst_time[$i]))
        turnaround_time[$i]=$((completion_time[$i]-arrival_time[$i]))
        sum_waiting_time=$((sum_waiting_time+waiting_time[$i]))
        sum_turnaround_time=$((sum_turnaround_time+turnaround_time[$i]))
        gannt_chart[$i]=${process[$i]}
    done
    gc=$number
    print_result
}

SJF_Nonpre(){
    completion_time[0]=$((arrival_time[0]+burst_time[0]))
    waiting_time[0]=0
    turnaround_time[0]=$((arrival_time[0]+burst_time[0]))
    sum_waiting_time=0
    sum_turnaround_time=$((arrival_time[0]+burst_time[0]))
    gannt_chart[0]=${process[0]}
    beg=1
    for ((i = 1; i<$number; i++))
    do
        for ((j = $i; j<$number; j++))
        do 
        if [ ${completion_time[$i-1]} -ge ${arrival_time[$j]} ]
            then
                readyqueue[$count]=$j
                count=$((count+1))
            else
                break
            fi
        done
        local m=0
        local n=0
        local min=${readyqueue[0]}
        for ((m=0; m<$count; m++))
        do
            if [ ${burst_time[ ${min}]} -gt ${burst_time[ ${readyqueue[$m]} ]} ]
            then
                min=${readyqueue[$m]}
                n=$m
            fi
        done

        p=${arrival_time[$min]}
        arrival_time[$min]=${arrival_time[$beg]}
        arrival_time[$beg]=$p

        p=${burst_time[$min]}
        burst_time[$min]=${burst_time[$beg]}
        burst_time[$beg]=$p

        p=${priority[$min]}
        priority[$min]=${priority[$beg]}
        priority[$beg]=$p

        p=${process[$min]}
        process[$min]=${process[$beg]}
        process[$beg]=$p

        gannt_chart[$i]=${process[$i]}
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
    gc=$number
    print_result
}

SJF_Pre(){
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
        local m=0
        local n=0
        min=${readyqueue[0]}
        for ((m=0; m<$count; m++))
        do
            if [ ${rem_time[ ${min}]} -gt ${rem_time[ ${readyqueue[$m]} ]} ]
            then
                min=${readyqueue[$m]}
                n=$m
            fi
        done
        flag1=0
        if [ $count -gt 0 ]
        then
            for ((i=0 ;i<$cur_time; i++))
            do
                if [ ${gannt_chart[$i]} -eq ${process[$min]} ]
                then
                    flag1=1
                fi
            done
        fi
        if [ $flag1 -eq 0 ] && [ $count -gt 0 ]
        then
            waiting_time[$min]=$((cur_time-arrival_time[$min]))
        fi
        if [ $count -gt 0 ]
        then
            gannt_chart[$cur_time]=${process[$min]}
            rem_time[$min]=$((rem_time[$min]-1))
        else
            gannt_chart[$cur_time]=$(echo " ")
        fi
        
        cur_time=$((cur_time+1))
        count=0
    done
    gc=$cur_time
    print_result
}

Priority(){
    completion_time[0]=$((arrival_time[0]+burst_time[0]))
    waiting_time[0]=0
    turnaround_time[0]=$((arrival_time[0]+burst_time[0]))
    sum_waiting_time=0
    sum_turnaround_time=$((arrival_time[0]+burst_time[0]))
    gannt_chart[0]=${process[0]}
    beg=1
    for ((i = 1; i<$number; i++))
    do
        for ((j = $i; j<$number; j++))
        do 
        if [ ${completion_time[$i-1]} -ge ${arrival_time[$j]} ]
            then
                readyqueue[$count]=$j
                count=$((count+1))
            else
                break
            fi
        done
        local m=$beg
        local n=0
        local max=${readyqueue[0]}
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

        gannt_chart[$i]=${process[$i]}
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
    gc=$number
    print_result
}

RoundRobin(){
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
        if [ $beg -ne $count ]
        then
            min=${readyqueue[$beg]}
            #echo "min: $min"
            #echo "cur: $cur_time"
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
                #echo -e "arrival time: ${arrival_time[$min]} process: ${process[$min]} $cur_time"
                waiting_time[$min]=$((cur_time-arrival_time[$min]))
            fi
            local m=0
            local n=0
            if [ $p_time -lt $tq ] && [ ${rem_time[$min]} -gt 0 ]
            then
                rem_time[$min]=$((rem_time[$min]-1))
                p_time=$((p_time+1))
                cur_time=$((cur_time+1))
                in_rq[$min]=1
                gannt_chart[$gc]=${process[$min]}
               #echo "gc: ${gannt_chart[$gc]}"
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
        else
            cur_time=$((cur_time+1))
            gannt_chart[$gc]=$(echo " ")
            gc=$((gc+1))
        fi
    done
    print_result
}

input
sort_arrival_time
echo -e "1) First Come First Serve \n2) Shortest Job First Non-Preemptive \n3) Shortest Job First Preemptive\n4) Priority based non-preemtive\n5) Round Robin"
read -p "Enter type of Job Scheduling: " c
case $c in
    1) FCFS;;
    2) SJF_Nonpre;;
    3) SJF_Pre;;
    4) Priority;;
    5) RoundRobin;;
esac