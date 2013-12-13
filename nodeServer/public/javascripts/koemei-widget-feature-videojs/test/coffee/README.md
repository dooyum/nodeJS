## CoffeeScript

It's not just about prettier and easier to read code, it's also about more agile!

 - nicer syntax
 - uses the finest solutions of JS
 - loop comprehensions
 - variable safety
 - splats
 - array slicing
 - destructuring assignment
 - string interpolation
 - chained comparisons
 - classes
 - @, -> and =>

Here are some references:
 - [Official website](http://coffeescript.org/)
 - [A CoffeeScript Intervention](http://pragprog.com/magazines/2011-05/a-coffeescript-intervention)
 - [Js2coffee](http://js2coffee.org/) *(not 100% reliable, use with care)*
 - [CoffeeScript Cookbook](http://coffeescriptcookbook.com/)
 - [Why you should use CoffeeScript](http://blog.gorges.us/2011/05/why-you-should-use-coffeescript/)


## Some tips & tricks

Assign arguments in constructor to properties of the same name:

```coffee
class Hello
  constructor: (@a, @b) ->
# is the same as:
class Hello
  constructor: (a, b) ->
    @a = a
    @b = b
```

Execute a function with no arguments:

```coffee
lcword = do str.toLowerCase
# is the same as:
lcword = str.toLowerCase()
```

Some iterations:

```coffee
(marker.remove()) for marker in @markers

for key, value of object
  # do things with key and value

for own key, value of object
  # do things with object's own properties only

for key, value of object when key in ['foo', 'bar', 'baz']
  # iterate through properties that meet the when condition

foobar = (value for key, value of object when key in ['foo', 'bar'])

for x in [1..100] by 10
  # iterate from 1 to 100 in steps of 10
```

Difference between -> and =>

```coffee
class Test
  abc: 'ABC'

  someMethod: ->
    # using the regular arrow (->)
    some_button.click ->
      # as usual, 'this' refers to the button
      console.log @src

    # using the fat arrow (=>)
    other_button.click =>
      # here, 'this' is the value of 'this' outside the scope of this function
      console.log @abc
```

## Building without Grunt

Our *Gruntfile* already builds CoffeeScript automatically, but if you still want to run a single file, here are some tips.

First, check these [tools](https://github.com/jashkenas/coffee-script/wiki/Build-tools) and [plugins](https://github.com/jashkenas/coffee-script/wiki/Text-editor-plugins) - your code editor may already have some plugin to build it.


### Terminal-based

To properly build the scripts, you will also need `coffeescript` interpreter and compiler for Node.js *(available in most Linux repositories or in the official [website](http://coffeescript.org/))*

```bash
$ cd <FOLDER_WITH_COFFEESCRIPTS>
$ coffee -wbc -o <FOLDER_WITH_JS> *.coffee
```

This will watch for any modifications on all your `.coffee` files and compile them to a destination folder


### If you use Sublime

To automate the build system, please correct the default script `<Package Folder>/Coffeescript/CoffeeScript-sublime.build`:

```js
    "cmd": ["cake", "sbuild"]
```

for

```js
    "cmd": ["coffee", "-cb", "$file"]
```

If you want to compress the JavaScript output, use this instead (it requires the [UglifyJS](https://github.com/mishoo/UglifyJS) tool):


```js
    "cmd": ["coffee -cbp ${file} | uglifyjs -nc -o ${file_path}/${file_base_name}.js"]
,   "shell": true
```


---

Authors:
 - Renato Martins
