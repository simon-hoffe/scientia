#!/bin/bash
let nowSerial=$(date +"%s")
let gitLastCommit=$(git log -1 --pretty=format:%ct)
git ls-files -o  --exclude-standard | \
while read fn ; do
#if [ "$(( $nowSerial - $(stat -c "%W" "$fn") ))" -lt "$(( 3600 * 48 ))" ]; then
#	   echo "$fn is recently created"
#	fi
	let newCreation=0
	let newModification=0


	if [ $gitLastCommit -lt $(stat -c "%W" "$fn") ]; then
	   	let newCreation=1
	fi

	if [ $gitLastCommit -lt $(stat -c "%Y" "$fn") ]; then
		let newModification=1
	fi

	outStr="$fn"

	if [[ $newCreation -eq 1 || $newModification -eq 1 ]]; then
		if [[ $newCreation -eq 1 ]]; then
			outStr="$outStr : NEW"
		else
			outStr="$outStr : ---"
		fi

		if [[ $newModification -eq 1 ]]; then
			outStr="$outStr : MOD"
		else
			outStr="$outStr : ---"
		fi

		echo "$outStr"
	fi
done



