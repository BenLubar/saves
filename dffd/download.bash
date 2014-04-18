#!/bin/bash

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
	rm -r "${d%.dat}"
	mkdir "${d%.dat}"
	cd "${d%.dat}"
	7z x "../$d"
	cd ..
done
