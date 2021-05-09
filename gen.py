symbols = "#STKPWHRAO*EUFRPBLGTSDZ"

count = 1
binary = '{:023b}'.format(count) 
until = 2**23-1
vowels = set(["A", "O", "*", "E", "U"])
numbers = "#12K3W4R50*EU6R7B8G9SDZ"

while count != until:
    binary = '{:025b}'.format(count) 
    lst = [int(d) for d in str(binary)[2:]]
    number = lst[0] == 1
    hashNeeded = False
    if number:
        hashNeeded = True
    ret = []
    for x in range(0, 23):
        if number and x == 0:
            next
        else:
            if lst[x] == 1:
                if number:
                    ret.append(numbers[x])
                    if numbers[x].isnumeric():
                        hashNeeded = False
                else:
                    ret.append(symbols[x])
            else:
                ret.append("")
    count = count + 1
    if not vowels.intersection(ret):
        ret[10] = "-"
    if hashNeeded:
        ret = ["#"] + ret
    print("".join(ret))
