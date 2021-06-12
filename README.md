# steno-stuff
> a random collection of steno related scripts and programs

## `suffix.py`
Reading from a dictionary, work out all the left-hand chords that are unused.
This can be helpful for creating a dictionary, as when you pick an unused left-hand chord the rest of the keys are free to be assigned with no clashes. 
left-hand in this case is `STKPWHR`

## `prefix.py`
Reading from a dictionary, work out all the right-hand chords that are unused.
This can be helpful for creating a dictionary, as when you pick an unused right-hand chord the rest of the keys are free to be assigned with no clashes. 
right-hand in this case is `FRPBLGTSDZ`

## `stenodecode.py`
Read in a binary file saved to my SD card from my Stentura Fusion, and translate it to raw steno tape output.
This allows me to retrieve the text I have written without a realtime connection to plover, and without any specialist software.
The plover plugin "plover-cat" can be used to translate the raw steno tape output back into text using your loaded dictionaries. 

## `gen.py`
Generate all possible chords from a single stroke and print them. Useful for piping though or using with a python dictionary to generate a `.json` of all the possible strokes.

## `powerset.sh`
Generate all combinations of specified keys, doesn't create valid steno strokes, so more useful for finding endings or starters to strokes. 
The current version shows an example of how I would use it to count all the possible endings within a given steno dictionary to find useful clash-free combinations. 

## `p2.erl`
A phrase analysis tool written in Erlang.
Given a text dataset as input, as well as a limit of how many words maximally exist in a phrase, and finally a list of threads to run with (should be the same as the previous number), this script will locate all possible words and phrases in this text and organise them by some metric. 
This metric tends to be a function of the number of occurances and how many words exist in that phrase. Thus words or phrases that appear multiple times will be ranked higher, and are thus more suitable to be added into a steno dictionary. 
This code as it currently stands does not handle multi Gigabyte text corpuses very well, as the text corpus will be stroked multiple times over in small segments to track phrase occurance. 
I've easily ran out of 128Gb of RAM with this script, so it's best kept to small relevant datasets (or being improved/re-written).
"p2.erl" stands for __p__hrase analyser version __2__.

