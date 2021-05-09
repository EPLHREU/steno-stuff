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
