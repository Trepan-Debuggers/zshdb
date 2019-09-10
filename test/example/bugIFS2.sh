#/!bin/zsh

typeset -p IFS
arr=($(echo -e "1\n2\n3"))

for temp in ${arr[@]}
do
    echo "temp = $temp"
done
