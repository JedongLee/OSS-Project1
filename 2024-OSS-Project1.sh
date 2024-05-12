#! /bin/bash

Menu1(){
        read -p "Do you want to get the Heung-Min Son's data? (y/n) :" c
        if [ "$c" == "y" ]; then
                cat $1 | awk -F, '$1~"Heung-Min"{printf "Team:%s, Apperance:%s, Goal:%s, Assist:%s", $4,$6,$7,$8}' 
        else
                return
        fi

}

Menu2(){
	read -p "What do you want to get the team data of league_position[1~20] : " position
	cat $1 |  awk -F, -v a=$position '$6 == a {winrate = $2/($2+$3+$4); print a,$1,winrate}'  
}

Menu3(){
	read -p "Do tou want to know Top-3 attendance data? (y/n) : " choice
	if  [ $choice == "y" ];then
		echo "***Top-3 Attendance Match***"
		cat $1 | awk -F, '{print $2","$0}' | sort -r -k 1 -n | head -n 3 | awk -F, '{printf "\n%s VS %s (%s)\n%s %s\n", $4,$5,$2,$3,$8}'
	else
		return
	fi

}


Menu4(){
	read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " choice
	if [ $choice == "y" ];then
		cat $1 | awk -F, 'NR > 1{print $6":"$1}' | sort -k 1 -n > b.txt
		IFS=$'\n'
		a=1
		for var in $(cat b.txt)
		do
			echo
			team=$(echo $var | cut -d: -f2)
			echo $a" "$team
			cat $2 | awk -F, -v t=$team -v count=$a '$4 == t{print $1","$7}' | sort -t, -k2 -n -r |  head -n 1 | tr "," " "
	
			a=$((a+1))
		done
	fi

}

Menu5(){
	read -p "Do you want to modify the format of date? (y/n) : " choice5
	if [ "$choice5" == 'y' ]
	then
		cat $1 | awk -F, 'NR > 1{print $1}' | sed -E 's/Aug/08/' | sed -E 's/Sep/09/' | sed -E 's/Oct/10/' | sed -E 's/Nov/11/' | sed -E 's/Dec/12/' | sed -E 's/Jan/1/' | sed -E 's/Feb/2/' | sed -E 's/Mar/3/' | sed -E 's/Apr/4/' | sed -E 's/May/5/' | awk '{print $3"/"$1"/"$2,$5}' | head -n 10 
	fi
}

Menu6(){	
	for i in $(seq 1 10)
	do
		cat $1 | awk -F, 'NR > 1 {printf "%s\n", $1}' | awk -v b=$i 'NR	== b {printf "%2d) %-25s", b,$0}'
		cat $1 | awk -F, 'NR > 1 {printf "%s\n", $1}' | awk -v b=$((i + 10)) 'NR == b {printf "%2d) %s\n",b,$0}'
	done
	read -p "Enter your team number : " team_number
	team=$(cat $1 | awk -F, 'NR > 1 {printf "%s\n", $1}' | awk -v tm=$team_number 'NR == tm {print $0}')
	
	max_score=$(awk -F, -v t="$team" '$3 == t && $5 > $6 {print $5 - $6}' $2 | sort -n | tail -n 1)
	
	awk -F, -v t="$team" -v max="$max_score" '$3==t && ($5 - $6) == max {print "";print $1;print $3" "$5" vs "$6" "$4}' $2
	
}


interface(){
	echo "************OSS1 - Project1************"
	echo "*      StudentID : 12214191           *"
	echo "*      Name : Jedong Lee              *"
	echo "***************************************"

	choice=0
	while [ : ]
	do
		echo
		echo
		echo "[MENU]"
		echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
		echo "2. Get the team data to enter a league position in teams.csv"
		echo "3. Get the Top-3 Attendance matches in mateches.csv"
		echo "4. Get the team's league position and team's top scorer in teams.csv & player.csv"
		echo "5. Get the modified format of date_GMT in matches.csv"
		echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
		echo "7. Exit"
		read -p "Enter your CHOICE(1~7) : " choice
		case "$choice" in
		"1")
		       	Menu1 $2;;
		"2")
			Menu2 $1;;
		"3")
			Menu3 $3;;
		"4")
			Menu4 $1 $2;;
		"5")
			Menu5 $3;;
		"6")
			Menu6 $1 $3;;
		"7")
			echo "Bye!"
			echo
			return
		esac
	
	done
}
if [ "$#" -ne 3 ];then
	echo "usage: $0 file1 file2 file3"
	echo
else
	interface $1 $2 $3
fi

