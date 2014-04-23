#!/bin/bash -e

while read -r url
do
	fn="dffd-gen-`sed -e 's/^.*\?id=//' -e 's/&.*$//' <<< "$url"`.dat"
	test -f "$fn" || wget -O"$fn" "$url"
done < list-gen.txt

while read -r url
do
	fn="dffd-com-`sed -e 's/^.*\?id=//' -e 's/&.*$//' <<< "$url"`.dat"
	test -f "$fn" || wget -O"$fn" "$url"
done < list-com.txt

for d in dffd-*.dat
do
	test -d "${d%.dat}" && rm -r "${d%.dat}"
	mkdir "${d%.dat}"
	cd "${d%.dat}"

	# we're using 7-zip because we don't know what the archive format is.
	7z x "../$d"

	# tar.whatever needs to be "unzipped" twice.
	if [[ -f "${d%.dat}" ]]
	then
		mv "${d%.dat}" "${d%.dat}.tar"
		7z x "${d%.dat}.tar"
		rm "${d%.dat}.tar"
	fi

	rm -rf "__MACOSX"

	cd ..
done
