#!node_modules/.bin/coffee
# The Auto Grapher

This is basically a REPL that graphs functions for you.
On your freaking terminal.

    console.log "Welcome to The Auto Grapher. Please type a function."

To use, just `npm install` the dependencies and execute this README.


## Input syntax

What you're actually typing in the REPL is CoffeeScript, such as
`sin (x + sin x)` or `max(x, 2) % 3`. This CoffeeScript is compiled
into a JS function and evaluated with appropiate `x` values.

    coffee = require "coffee-script"
    vm = require "vm"

    compile = (inputCode) ->
      ast = coffee.nodes(inputCode).makeReturn()
      code = "x = function (x) { #{ast.compile {bare: yes}} };"
      vm.runInContext code, sandbox
      fn = sandbox.x

You can either write the expression directly, such as `sin(x)`, or
provide the function, such as `(x) -> sin(x)`. The result will be the
same, however the second form allows you to use your own variable name.

      r = fn 0
      if r.call? then r else fn

#### Environment

Your code is evaluated in the context of the `Math` object, so you can
use its properties and functions directly, i.e. `PI` or `atan2`, etc.

    sandbox = vm.createContext Math


## Plotting

We start by creating a 2D array, with the dimensions of `viewport`,
which has all slots set to a space. `range` contains the function
bounds to match to the viewport.

    plot = (fn, range, viewport) ->
      grid = for y in [0...viewport.height]
         " " for x in [0...viewport.width]

For each column we evaluate a point, round it to the nearest viewport
row, and set that slot to a "solid" character (U+2588), all while
taking care of the range-to-viewport mapping.

      for x in [0...viewport.width]
        rx = range.x + range.width * x / viewport.width
        y = viewport.height * -((fn rx) - range.y) / range.height
        y = Math.round y
        grid[y][x] = "█" if (y >= 0 and y < viewport.height)

We assemble the array into a series of lines, for printing into the console.

      grid.map((line) -> line.join "").join "\n"


## Prompt

There it is! The user interface. We read from the user, compile,
catch any syntax errors, and plot whatever the user entered in.

    readline = require "readline"
    rl = readline.createInterface {
      input: process.stdin,
      output: process.stdout
    }

    range = {x: -5, y: 1.5, width: 10, height: 3}

    rl.on "line", (input) ->
      try
        fn = compile input
        viewport = {width: process.stdout.columns-1, height: process.stdout.rows-1}
        console.log (plot fn, range, viewport)
      catch err
        console.error "What was that?"
      rl.prompt()

    rl.prompt()
