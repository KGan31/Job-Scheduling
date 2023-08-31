arr=()
echo "Enter number of elements: "
read n
echo -n "Enter $n Elements: "
for ((i=0; i<$n; i++))
do
    read arr[$i]
done

for ((i=0; i<$n; i++))
do 
    t=${arr[$i]}
    for ((j=$i; j>0; j--))
    do
        k=$((j-1))
        if [ $t -lt ${arr[ $k ]} ]
        then
            temp=${arr[ $k ]}
            arr[ $k ]=${arr[ $j ]}
            arr[ $j ]=$temp
        fi
    done
done

echo -n "Enter elements are "
for ((i=0; i<$n; i++))
do
    echo "${arr[$i]} "
done