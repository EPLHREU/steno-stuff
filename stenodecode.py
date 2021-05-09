# decode the raw files saved to the SD card of my Stentura Fusion into raw steno tape
# this can be used with something like plover-cat to obtain the original text written
# use like so: 'python stenodecode.py 001.file output.txt'

import sys

i = open(sys.argv[1], 'rb')
o = open(sys.argv[2], 'w')

stenoOrder = "#STKPWHRAO*EUFRPBLGTSDZ"

chord = []
for byte in i.read():
    chord.append(byte)
    if len(chord) == 4:  # 4 bytes per stroke, accumulate them all
        binary = []
        for byte in chord:
            binary.append("{0:b}".format(byte))
        if binary[0][0:2] == binary[1][0:2] == binary[2][0:2] == binary[3][0:2] == '11':  # only read steno strokes, not controls
            keys = ""
            for b in range(4):
                keys = keys + binary[b][2:8]  # ignore the first 2 control bits
            keys = keys[1:]
            steno = ""
            for s in range(23):
                if keys[s] == '1':
                    steno = steno + stenoOrder[s]
                else:
                    steno = steno + " "
            o.write(steno)
            o.write("\n")
        chord = []
o.close()
