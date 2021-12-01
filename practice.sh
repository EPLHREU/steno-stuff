 cut -f2 -d '	' Magnum\ Steno\ Theory.txt | shuf | head -n 100 | sed ':a; N; s/\n/ /; ta' | speedpad
