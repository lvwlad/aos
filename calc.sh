#!/bin/bash

function calculate() {
        result=0
        case $1 in
                'sum')
                        shift
                        set $1 # тут разделяем позиционный параметр на нескольо частей
                        for num in $@; do
                                result=$(($result+$num))
                        done
                        ;;
                'mul')
                        shift
                        result=1

                        for num in $@; do
                                result=$(($result*$num))
                        done
                        ;;
                'sub')
                        shift
                        set $1
                        result=$1
                        shift
                        for num in $@; do
                                result=$(($result-$num))
                        done
                        ;;
                'div')

                        shift
                        set $1
                        result=$1
                        shift
                        for num in $@; do
                                if [[ $num -eq 0 ]]; then
                                        echo 'error: division on zero' >> log_file.log
                                else
                                        result=$(($result/$num))
                                fi
                                done
                        ;;
                'pow')

                        shift
                        set $1
                        result=$1
                        shift
                        for num in $@; do
                                result=$(($result**$num))
                        done
                        ;;

                *)
                        echo "invalid operation"
                        ;;

        esac
        echo $result
}


function set_operation(){
        if [[ $1 == '-o' ]]; then
                declare -A ops=(['sum']=1 ['sub']=1 ['mul']=1 ['div']=1 ['pow']=1)
                if [[ ${ops[$2]} ]];then
                        echo $2
                else
                        echo "erior: invalid operation $2" >> $3
                        exit
                fi
         else
                 echo "error: invalid option '$1'" >> $3
                exit
        fi
}

function set_numbers(){
        if [[ $1 == '-n' ]]; then
                        echo $2
                else
                        echo "error: invalid options $1" >> $3
                        exit
        fi

}


if [[ $# -eq 6 ]]; then
        if [[ $5 == '-l' ]]; then
                operation=$(set_operation "$1" "$2" "$6")
                echo $operation
                numbers=$(set_numbers "$3" "$4" "$6")
                echo $numbers
                result=$(calculate "$operation" "$numbers")
                echo "Результат: $result"
        else
                echo 'error'
                exit
        fi
else
        echo 'error'
fi
