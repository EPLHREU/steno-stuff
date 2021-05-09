# show all unused right hand chords in a dictionary
import re, itertools, json; print(sorted(set(map(lambda b: "".join(map((lambda p: p[1] if p[0] else ""), zip(b, "FRPBLGTSDZ"))), itertools.product((0, 1), repeat=11))).difference(re.search("\*?F?R?P?B?L?G?T?S?D?Z?$", s).group(0) for ks in json.load(open("magnum.json")).keys() for s in ks.split("/")), key=len))
