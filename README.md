# Effective Novel Core

This is novel text parse and stream provide package.

## About
This is novel engine.

This effectively helps to display the characters of the novel.　　

This lib doesn't include UI layer.
This only provides parse and output stream display event. (I'm going to will link CLI and iOS Example.)

Also, this lib is not optimized novel game.  
Because this doesn't have if functioned, macro, subroutine.

## Syntax

### Syntax Tags
Tags must be enclosed in `[]`.

| tag              | DisplayEvent            | mean                                                                |
|------------------|-------------------------|---------------------------------------------------------------------|
| n                | `.newline`              | newline                                                             |
| tw               | `.tapWait`              | tap wait                                                            |
| twn              | `tapWaitAndNewline`     | tap wait and newline                                                |
| cl               | `.clear`                | clear                                                               |
| delay speed=xxxx | `.delay(speed: Double)` | change delay character displayed speed. speed unit is milliseconds. |
| resetdelay       | `.resetDelay`           | reset delay speed                                                   |
| e                | `.end`                  | stop script novel end point                                         |


### Example Novel Text

```
start text[n]

tap waiting and newline[twn]

[cl] cleared text.

very fast stream after this text[delay speed=2][n]

[resetdelay]reset delay speed.[n]

end. [e]
```

## Usage

```swift

// 1. get `NovelController` instance
let controller = NovelController()

// 2. load raw novel text
controller.load(rawText: rawText)

// 3. start() and listening stream
controller.start()
          .sink { event in
              switch event {
              case .character(let char):
                  displayCharacter(char)
              // and any command handling
              }
          }
          .store(in: &cancellables)

// (4.) show text until wait tag
controller.showTextUntilWaitTag()

// (5.) resume tap wait
// If you want to start from any index number, you can use `controller.resume(at: 100)`
controller.resume() 

// (6.) interrupt
controller.interrupt()


```



## Examples
- [ ] CLI novel reader
- [ ] iOS novel reader

## Todo
- [ ] value input
- [ ] novel text validator
