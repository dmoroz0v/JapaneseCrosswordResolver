# JapaneseCrosswordResolver

# Example

![alt tag](https://github.com/dmoroz0v/JapaneseCrosswordResolver/blob/master/example.png)


```swift

let x = [
    [3],
    [4],
    [3, 5],
    [3, 6],
    [3, 7],

    [3, 8],
    [3, 4, 2],
    [3, 4, 2, 2],
    [2, 5, 2],
    [3, 4, 2, 2],

    [3, 4, 2],
    [3, 8],
    [3, 7],
    [5, 6],
    [6, 5],

    [4],
]

let y = [
    [3],
    [5],
    [3, 3, 2],
    [3, 1, 5],
    [3, 3, 4],

    [3, 5, 3],
    [3, 7, 3],
    [3, 9, 2],
    [2, 4, 4, 1],
    [6, 1, 1, 5],

    [4, 1, 1, 4],
    [4, 4],
    [13],
    [13],
]


let resolver = JapaneseCrosswordResolver()

let solution = resolver.resolve(x: x, y: y)

solution.forEach { solutionRow in
    print(solutionRow)
}

...
```
