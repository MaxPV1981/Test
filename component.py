from collections import deque

G = {'A':{'B'}, 'B':{'C','D'}, 'C':{'A'}, 'D':{'E'}, 'E':{'F'}, 'F':{'D'},\
     'G':{'F','H'}, 'H':{'I'}, 'I':{'J'}, 'J':{'G'}, 'K':{'J'}}

def kosaraju(G):
    used = []
    stack = deque()
    num = 0
    cycle_found = False
    def dfs(vertex):
        """
        Обход в глубину с заполнением стека именами вершинами
        """
        nonlocal G
        nonlocal used
        nonlocal stack
        used.append(vertex)
        stack.append(vertex)
        for neightbor in G[vertex]:
            if neightbor in G and neightbor not in used:
                dfs(neightbor)

    def dfs_reversed(vertex, used_local=None):
        """
        Обход в глубину  в обратную сторону. Для проверки вершины использует
        модифицируемый used.
        
        """        
        nonlocal G
        nonlocal used
        nonlocal num
        nonlocal cycle_found
        cycle_found = False
        used_local = used_local or []
        for candidate in used_local:
            if vertex in G.get(candidate) and not cycle_found:
                cycle_found = True
                num += 1
                print("Найден цикл: " + str(used_local + [vertex]))
        used_local.append(vertex)
        used.append(vertex)
        for key in G:
            if vertex in G.get(key) and key not in used and key not in used_local:
                dfs_reversed(key, used_local)
        if len(used_local) == 1:
                cycle_found = True
                num += 1
                print("Найдена вершина: " + str(vertex))
                
    def stack_down():
        """
        Обработка заполненного стека вызовом обхода в глубину в обратную сторону
        для всех ещё не пройденных вершин.
        """
        nonlocal G
        nonlocal used
        nonlocal num
        nonlocal stack
        element = stack.pop()
        if element not in used:
            dfs_reversed(element)

    for vertex in G:
        if vertex not in used:
            dfs(vertex)
    used = [] #Нужно очистить, т.к. dfs_reversed, вызываемая stack_down, будет заполнять его заново
    while len(stack) > 0:
        stack_down()
    print("Количество компонент сильной связности: " + str(num))

kosaraju(G)
