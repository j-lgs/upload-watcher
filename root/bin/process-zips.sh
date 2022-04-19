#!/bin/bash
inbox="$2"
betanin_apikey="$3"
betanin_host="$4"
ext=""
case "$1" in
    *.7z)  7za -y x "$1" >> /dev/null; ext=".7z" ;;
    *.zip) 7za -y x "$1" >> /dev/null; ext=".zip" ;;
    *)     exit 0 ;;
esac
echo "File $1 processed. Deleting now."
rm -f "$1"
betanin_name=$(basename "$1" "$ext")

echo "Determining whether the file must be split and tagged."
cd "$betanin_name"
audio_files=$(find . -regex  ".*\.\(flac\|tta\|ape\)")
n_audio_files=$(echo "$audio_files" | wc -l)
n_cues=$(find . -name "*.cue" | wc -l)
if [ "$n_audio_files" == "1" ] && [ "$n_cues" == "1" ]; then
    betanin_name="[split] $betanin_name"
    mkdir ../"$betanin_name"
    case "$audio_files" in
	*.tta)
            find . -name "*.cue" -execdir sh -c \
		 'shnsplit -f "$1" -t "%n_%p-%t" -o flac -d "../$2" "${1%.cue}.tta"' _ {} "$betanin_name" \;
	    ;;
	*.ape)
            find . -name "*.cue" -execdir sh -c \
		 'shnsplit -f "$1" -t "%n_%p-%t" -o flac -d "../$2" "${1%.cue}.ape"' _ {} "$betanin_name" \;
	    ;;
	*.flac)
	    find . -name "*.cue" -execdir sh -c \
		 'shnsplit -f "$1" -t "%n_%p-%t" -o flac -d "../$2" "${1%.cue}.flac"' _ {} "$betanin_name" \;
	    ;;
	*)
	    echo "ERROR: Invalid file made it through. Abort!"
	    exit 1
	    ;;
    esac
    echo "Tagging split album."
    find . -name "*.cue" -execdir sh -c \
	 'cuetag.sh "$1" "../$2/"*.flac 2> /dev/null' _ {} "$betanin_name" \;
    # Correct Permissions
    find . "../$betanin_name" -type d -exec chmod 0755 {} \;
    find . "../$betanin_name" -type f -exec chmod 0644 {} \;
    chown -R nobody:nogroup . "../$betanin_name"
    cp *.mp3 "../$betanin_name"
fi

cd "$inbox"

echo "Notifying Beets of the new album."
echo "$inbox $betanin_name $betanin_apikey $betanin_host"
curl --request POST \
     --data-urlencode "path=$inbox" --data-urlencode "name=$betanin_name" \
     --header "X-API-Key: $betanin_apikey" "$betanin_host"
