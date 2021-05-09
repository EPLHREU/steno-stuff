# from https://unix.stackexchange.com/questions/309956/permutations-in-bash-combinations-of-ids-tokens
# useful for searching through all endings or starters in a dictionary

function binpowerset() (
  list=($@)
  eval binary=( $(for((i=0; i < ${#list[@]}; i++)); do printf '%s' "{0..1}"; done) )
  nonempty=0
  for((power=0; power < ${#binary[*]}; power++))
  do
    binrep=${binary[power]}
    for ((charindex=0; charindex < ${#list[*]}; charindex++))
    do
      if [[ ${binrep:charindex:1} = "1" ]]
      then
         printf "%s" ${list[charindex]}
         nonempty=1
      fi
    done
    [[ $nonempty -eq 1 ]] && printf "\n"
  done
)

for search in $(binpowerset L G T S D Z); do echo $search; grep "$search\"" magnum.json | wc -l; done
