function calculate(){
        case $1 in
                'sum')
                        shift
                        set $1
                        result=$1
                        shift
                        for number in $@;do
                                result=$(($result+$number))
                        done
                        echo $result
                        ;;
                *)

                        echo "$(date) error: invalid operation "
                        echo "$(date) error: invalid operation"  >> $3
                        ;;
        esac
}

function set_operation(){
        if [[ $1 == '-o' ]];then
                declare -A ops=(['sum']=1 ['sub']=1 ['mul']=1 ['pow']=1 ['div']=1)
                if [[ ${ops[$2]} ]];then
                        echo $2
                else
                        echo "$(date) error: invalid operation '$2'"
                        echo "$(date) error: invalid operation '$2'" >> $3
                        exit
                fi
        else
                echo "$(date) error: invalid option '$1'"
                echo "$(date) error: invalid option '$1'" >> $3
                exit
        fi
}

function set_numbers() {
        if [[ $1 == "-n" ]];then
                echo "$2"
        else
                echo "$(date) error: invalid option '$1'"
                echo "$(date) error: invalid option '$1'" >> $3
                exit
        fi
}

if [[ $# -eq 6 ]];then
        if [[ "$5" == "-l" ]];then
                operation=$(set_operation "$1" "$2" "$6")
                numers=$(set_numbers "$3" "$4" "$6")
                echo "$(calculate "$operation" "$numers")"
        else
                echo "$(date) error: invalid option '$5'"
                echo "$(date) error: invalid option '$5'" >> $3
        fi
else
        echo "$(date) error: invalid syntax"
        echo "$(date) error: invalid option" >> $3
fi
