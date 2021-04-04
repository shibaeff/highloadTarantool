l=$(ps aux | grep tarantool | tr -s ' ' | cut -f2 -d' ' | sed '$ d' | tr '\n' ' ')
if [[ $l != "" ]]
then
  kill -9 $l
fi