#!/bin/bash
set -e

usage() {
  echo "USAGE: $(basename $0) -f FILE [-e FILE_EXT] [-t FILE_TYPE] [-u USER_AGENT]" >&2
  echo "  FILE       = path to file to upload"
  echo "  FILE_EXT   = extension of file to upload, 'mp4' by default"
  echo "  FILE_TYPE  = type of file to upload, will be 'video/mp4' by default"
  echo "  USER_AGENT = UA string to use when communicating with Curl, will be set to Edge by default"

  exit 1
}

unset FILE
unset FILE_EXT
unset FILE_SIZE
unset FILE_TYPE
unset USER_AGENT


while getopts ":f:e:t:u" o; do
    case "${o}" in
        f)
            FILE=${OPTARG}
            ;;
        e)
            FILE_EXT=${OPTARG}
            ;;

        t)
            FILE_TYPE=${OPTARG}
            ;;

        u)
            UA=${OPTARG}
            ;;

        *)
            usage
            ;;
    esac
done

if [ -z "$FILE" ]  || [ ! -f $FILE ]; then
  echo "Cannot find $FILE" >&2
  usage
else
  FILE_SIZE=$(wc -c < "$FILE")
fi

if [ -z "$FILE_EXT" ]; then
  FILE_EXT="mp4"
fi

if [ -z "$FILE_TYPE" ]; then
  FILE_TYPE="video/mp4"
fi

if [ -z "$UA" ]; then
  UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.74 Safari/537.36 Edg/79.0.309.43"
fi


CSRF=$(curl -s -A "$UA" -c cookies.txt -b cookies.txt "https://forms.donaldjtrump.com/landing/wish-president-trump-a-happy-birthday?utm_medium=social&utm_source=djt_tw&utm_campaign=20200604_12_birthday-card_teamtrump" | grep "window.axios.defaults.headers.common.*" | sed -n "s/^.*\"\(.*\)\";$/\1/p")

FILE_NAME=$(head /dev/urandom | LC_ALL=C  tr -dc A-Za-z0-9 | head -c10)

CURL_FORM_INFO=$(curl -s -c cookies.txt -b cookies.txt -H "X-CSRF-TOKEN:${CSRF}" -A "$UA" -X POST -d "{\"filename\": \"${FILE_NAME}\", \"extension\": \"${FILE_EXT}\", \"size\": ${FILE_SIZE}, \"type\": \"${FILE_TYPE}\"}" https://forms.donaldjtrump.com/files/public/signed)

CURL_FORM_FLAGS=$(echo "$CURL_FORM_INFO" | jq -jr '.additionalData | to_entries|map(" -F \(.key)=\(.value|tostring)")|.[]')
CURL_FORM_DESTINATION=$(echo "$CURL_FORM_INFO" | jq -jr '.attributes.action')
curl -A "$UA" $CURL_FORM_FLAGS -F "file=@${FILE}" $CURL_FORM_DESTINATION
