#!/bin/bash -e

test -f "dffd-base.dat" || wget -O"dffd-base.dat" "http://www.bay12games.com/dwarves/df_34_11_linux.tar.bz2"
rm -rf "dffd-base"
mkdir "dffd-base"
cd "dffd-base"
7z x "../dffd-base.dat"
7z x "dffd-base"
rm "dffd-base"
mv "df_linux/"* .
rmdir "df_linux"
chmod +x "df" "libs/Dwarf_Fortress"
mkdir "data/save"
sed -i "data/init/init.txt" -e "s/\\[PRINT_MODE:2D\\]/[PRINT_MODE:TEXT]/"
sed -i "data/init/init.txt" -e "s/\\[SOUND:YES\\]/[SOUND:NO]/"
sed -i "data/init/init.txt" -e "s/\\[INTRO:YES\\]/[INTRO:NO]/"
cd ..

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

for d in dffd-{com,gen}-*.dat
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

	test -d "__MACOSX" && rm -r "__MACOSX"
	find . -name ".DS_Store" -delete
	find . -name ".DS_Store.*" -delete
	find . -name "._*" -delete
	if [[ ! -f world.dat && ! -f world.sav ]]
	then
		for i in */
		do
			if [[ -f "$i"world.dat || -f "$i"world.sav ]]
			then
				mv "$i"* .
				rmdir "$i"
				break
			fi
		done
	fi
	test -d "raw/graphics" && rm -r "raw/graphics"
	if [[ -f world.sav ]]
	then
		ln -s "`pwd`" "../dffd-base/data/save/region1"
		(echo -en '\n\n' && sleep 15 && echo -en '\e' && sleep 5 && echo -en '8\n' && sleep 5 && echo -en 'y' && sleep 5 && echo -en '\n' && sleep 15 && echo -en '8\n' && sleep 5 && killall Dwarf_Fortress || true) | ../dffd-base/df || true
		rm "../dffd-base/data/save/region1"
	fi

	cd ..
done
