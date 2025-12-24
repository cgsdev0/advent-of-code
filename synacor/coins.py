for p in itertools.permutations([9, 2, 3, 5, 7]):
    v=p[0]+p[1]*p[2]**2+p[3]**3-p[4]
        if v == 399:
            print(p)
