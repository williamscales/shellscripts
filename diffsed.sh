#!/bin/sh
# diffsed.sh
# by William Scales
# 2010-06-11
# 
# public domain
#
# recursively traverses the given directory (defaulting to .) looking
# for files matching the given pattern (defaulting to *) and run sed
# on them with the given expression. do some nice diff things to make
# sure you are making the changes you want to make.

# defaults
path='.'
pattern='.*'
verbose=false

USAGE="usage: $ diffsed.sh [options] -e expression\n
'expression' is a gnu sed expression using enhanced regex\n\n
options\n
-d|--path\t\t     path on which to operate.  defaults to .\n
-e|--expression\t expression which will be passed to sed. required.\n
-p|--pattern\t\t  perl regex to match filenames. defaults to .*\n
-v|--verbose\t\t  operate verbosely. e.g. print the filename we're operating on.\n"

while [ $# -gt 0 ]
do
  case "$1" in
  -d|--path )
    path=$2
    shift
    ;;
  -p|--pattern )
    pattern=$2
    shift
    ;;
  -e|--expression )
    expression=$2
    shift
    ;;
  -v|--verbose )
    verbose=true
  esac
  shift
done

if [ -z $expression ]
then
  echo expression required.
  echo $USAGE
  exit 1
fi

FILES=`find "$path" -type f | grep -P "$pattern"`

for file in $FILES
do
  if $verbose; then echo "$file"; fi
  sed -re "$expression" "$file" > "$file.n"
  if [ ! -z "`diff -q $file $file.n`" ]
  then
    diff -u "$file" "$file.n" | less -FX 
    read -p 'Overwrite (Y/n)? ' response
    case $response in
      'n' | 'N' )
        rm "$file.n"  
        ;;
      'y' | 'Y' )
        mv "$file.n" "$file"
        ;;
      * )
        mv "$file.n" "$file"
        ;;
    esac
  else
    rm "$file.n"  
  fi
done
