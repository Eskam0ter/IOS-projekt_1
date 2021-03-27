#!/bin/sh

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8

print_help()
{
  echo "Usage: tradelog [-h|--help]"
	echo "       tradelog [FILTR] [PŘÍKAZ] [LOG [LOG2 [...]]"
	echo ""
}
COMMAND=""
WIDTH=""
TICKER=""
DATE_BEFORE="9999-12-31 23:59:59"
DATE_AFTER="0000-00-00 00:00:00"
LOG_FILES=""
TFLAG=""
DAFLAG=""
DBFLAG=""
WCOUNT=0
NOPTARG=""


while getopts w:t:a:b:h-: opts
do case "$opts" in
   a) DAFLAG=1
      NOPTARG=$(echo "$OPTARG" | sed 's/-//g ; s/://g ; s/ //g')
      NDATE_AFTER=$(echo "$DATE_AFTER" | sed 's/-//g ; s/://g ; s/ //g' )
      if [ $NOPTARG -gt $NDATE_AFTER ]; then
        DATE_AFTER="$OPTARG"
      fi ;;

   b) DBFLAG=1
      NOPTARG=$(echo "$OPTARG" | sed 's/-//g ; s/://g ; s/ //g')
      NDATE_BEFORE=$(echo "$DATE_BEFORE" | sed 's/-//g ; s/://g ; s/ //g' )
      if [ $NOPTARG -lt $NDATE_BEFORE ]; then
        DATE_BEFORE="$OPTARG"
      fi ;;
   t) TICKER="$TICKER$OPTARG;"
      TFLAG=1;;
   w) WCOUNT=$(( $WCOUNT + 1 ))
      if [ "$WCOUNT" = 2 ]; then
          echo "Chybne spusteni"
          exit 0;
      fi
     WIDTH="$OPTARG";;
   h) print_help
      exit 0;;
   -) print_help
      exit 0;;
   *) echo "Invalid flag"
      exit 0;;
   esac
done

shift $(($OPTIND - 1))

while [ "$#" -gt 0 ]; do
  case "$1" in
  list-tick | profit | pos | last-price | hist-ord | graph-pos)
    COMMAND="$1"
    shift
    ;;
  *.log.gz)
    LOG_FILES="$LOG_FILES$(gzip -d -c "$1")\n"
    shift
    ;;
  *.log)
    LOG_FILES="$LOG_FILES$(cat "$1")\n"
    shift
    ;;
  *)
    echo "Invalid argument"
    exit 0
    ;;
  esac
done


if [ "$TFLAG" = "1" ]; then
    LOG_FILES=$(echo "$LOG_FILES" | awk -F ';' -v ticker="$TICKER" 'ticker~ $2";" {print}')
    echo "$LOG_FILES"
fi
if [ "$DAFLAG" = "1" ]; then
    LOG_FILES=$(echo "$LOG_FILES" | awk -F ';' -v after="$DATE_AFTER" '$1 > after {print}')
fi
if [ "$DBFLAG" = "1" ]; then
    LOG_FILES=$(echo "$LOG_FILES" | awk -F ';' -v before="$DATE_BEFORE" '$1 < before {print}')
fi
if [ "$COMMAND" = "list-tick" ]; then
    LOG_FILES=$(echo "$LOG_FILES" | awk -F ';' '{print$2}' |sort -u)
    echo "$LOG_FILES"
fi
#При выписе лист-тик первая строка пустая лишняя как убрать узнать(все из за сорта хз почему)
#пос - узнать почему там отрицательные ходноты
