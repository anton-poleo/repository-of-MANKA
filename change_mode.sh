#!/bin/bash

# Перечень пунктов меню
OPTIONS=(
    "1. Изменить права для владельца"
	"2. Изменить права для группы"
	"3. Изменить права для остальных"
	"4. Изменить права для всех"
	"q. Вернуться в главное меню"
)
OPTIONS_MODE=(
	"1. Добавить право записи"
	"2. Удалить право записи"
	"3. Добавить право чтения"
	"4. Удалить право чтения"
	"5. Добавить право исполнения"
	"6. Удалить право исполнения"
	"7. Добавить бит SUID"
	"8. Удалить бит SUID"
	"q. Вернуться назад"
)

choose_mode(){
	local err=0
	echo
	if [[ "$mode" == *u ]]; then
		echo "Изменение прав доступа к файлу "$2" для владельца"
	elif [[ "$mode" == *g ]]; then
		echo "Изменение прав доступа к файлу "$2" для группы"
	elif [[ "$mode" == *o ]]; then
		echo "Изменение прав доступа к файлу "$2" для остальных"
	else
		echo "Изменение прав доступа к файлу "$2" для всех"				  
	fi
	local i=0
	if [[ "$mode" == *u || "$mode" == *g ]]; then
		while [ "$i" -lt 9 ]
		do
			echo ${OPTIONS_MODE[i]}
			let "i += 1"
		done
	else
		while [ "$i" -lt 6 ]
		do
			echo ${OPTIONS_MODE[i]}
			let "i += 1"
		done
		echo ${OPTIONS_MODE[8]}
	fi
	read REPLY
	case $REPLY in
		"1")#+w
			mode=$1"+w"
		;;
		"2")#-w
			mode=$1"-w"
		;;
		"3")#+r
			mode=$1"+r"
		;;
		"4")#-r
			mode=$1"-r"
		;;
		"5")#+x
			mode=$1"+x"
		;;
		"6")#-x
			mode=$1"-x"
		;;
		"7")#+s
			if [[ "$mode" == *u || "$mode" == *g ]]; then
				mode=$1"+s"
			else
				echo "Неверный ввод!">&2
				let "err = 1"
			fi
		;;
		"8")#-s
			if [[ "$mode" == *u || "$mode" == *g ]]; then
				mode=$1"-s"
			else
				echo "Неверный ввод!">&2
				let "err = 1"
			fi
		;;		
		q) return;;
		*) echo "Неверный ввод!">&2
			let "err = 1"
		;;
	esac
	if [[ err -eq 1 ]]; then
		choose_mode "$1" $2
	else
		change_mode "$mode" $2
	fi
}

change_mode(){
	chmod $1 $2
	exit_code=$?
	if [[ exit_code -ne 0 ]]; then
		echo "Не получилось изменить права для файла "$2>&2
	else
		echo "Права доступа для файла "$2" были изменены"
	fi
}

while :
do
	mode=""
	if [[ $# -eq 2 ]]; then
		mode="-R "
	fi
	echo
	echo "Изменение прав доступа для файла "$1
	for opt in "${OPTIONS[@]}"
	do
		echo $opt
	done
	read REPLY
	case $REPLY in
	"1")#user
		mode=$mode"u"
		;;
	"2")#group
		mode=$mode"g"
		;;
	"3")#others
		mode=$mode"o"
		;;
	"4")#all
		mode=$mode"a"
		;;
	q) break;;
	*) echo "Неверный ввод!">&2
		continue
		;;
	esac
	choose_mode "$mode" $1
done	
