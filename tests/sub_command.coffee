{Pipeline, parsePipelines} = require '../pipeline'
tape = require 'tape'
util = require 'util'

_inspect = (o) -> util.inspect o, depth: null
inspect = (o) -> console.log _inspect o

# ======================
# INPUT DATA
# ======================

test_input = [
    name: 'bill',
    dogs: [
        name: 'sparky'
        age: 58
    ,
        name: 'woofer'
        age: 6
    ],
,
    name: 'fred',
    dogs: []
]

pipe = new Pipeline()
    .use 'keywords' # for slugify

test_ctx = pipe.subScope
    vars:
        hi: 'hello'
        world: 'earth'
        cheese: 'fromage'
        george:
            name: 'Gregory'

# ======================
# TESTS
# ======================

tests = {}

tests.first =
    cmd: """ obj name joe | echo $( @ name ) """
    expected: 'joe'

# Test using a sub-pipe within a sub-pipe
tests.sub_pipe  =
    cmd: """

        echo $(@ 0.name | . $(echo chee | . se) )

    """
    expected: 'billcheese'

# Test using a sub-pipe as an object value
tests.sub_val =
    cmd: """

        id seven @ :{
            name,
            dog_years: $(@dogs:age | + 0)
        }

    """
    expected: [
        name: 'bill',
        dog_years: 64
    ,
        name: 'fred',
        dog_years: 0
    ]

# Test using a sub-pipe as an object key
tests.sub_key =
    cmd: """ echo "Howdy, Earth!" @ {$( slugify ): .} """
    expected:
        'howdy-earth': 'Howdy, Earth!'

# Test using a sub-pipe as both a key and a value
tests.sub_key_val =
    cmd: """ echo "Howdy, Earth!" @ {$(echo phrase): {$( slugify ): .}} """
    expected:
        phrase:
            'howdy-earth': 'Howdy, Earth!'

# Test the series pipe
tests.spipe =
    cmd: """ list 4 5 6 |= + 5 """
    expected: [9, 10, 11]

# Test varable substitution
tests.sub_var =
    cmd: """ echo $hi """
    expected: 'hello'

# Test varable substitution
tests.multi_sub_var =
    cmd: """ echo "$hi $world" """
    expected: 'hello earth'

# Test character escapes alongside variables
tests.escd_quoted =
    cmd: """ echo "\\)=$cheese" """
    expected: ')=fromage'

# Test variables
tests.vars =
    cmd: """ $frank = 5 ; echo $frank """
    expected: '5'

# Test object variables, variable @-expressions, `;` separated results
tests.obj_cmd =
    cmd: """ {test: 'ok'} """
    expected: {test: 'ok'}
tests.obj_vars =
    cmd: """ $fred = {name: "Fred"} ; echo $( $fred @ name ) """
    expected: 'Fred'

# Boolean parsing and not parsing
tests.parse_bool =
    cmd: """ true """
    expected: true
tests.dont_parse_bool =
    cmd: """ trueth """
    expected: undefined

# Raw list syntax
tests.list_cmd =
    cmd: """ [1, 2, [3, 4]] @ 2.1 """
    expected: 4

# Lists and objects combined
tests.list_objs =
    cmd: """ [{name: "Jeorge", age: 55}, {name: "Fredrick", pets: ['Kangaroo', 'Dog']}] @ 1.pets.1 | reverse """
    expected: 'goD'

# Setting and using aliases
tests.set_alias =
    cmd: """ alias sayhi = echo "hello there" """
    expected:
        success: true
        alias: 'sayhi'
        script: 'echo "hello there"'
tests.use_alias =
    cmd: """ sayhi """
    expected: 'hello there'

# Parallel piping and @ing within
tests.test_ppipe =
    cmd: """ range 25 || obj id $! || id @ id """
    expected: [0..24]

# ======================
# EXECUTION
# ======================

# Print out the parsed command tree
showParsed = (cmd) ->

    console.log '\n~~~~~'
    console.log cmd + ' ->\n'
    inspect parsePipelines cmd
    console.log '~~~~~\n'

# Run a test
runTest = (test_name) ->

    tape test_name, (t) ->

        showParsed tests[test_name].cmd
        pipe.exec tests[test_name].cmd, test_input, test_ctx, (err, test_result) ->

            t.deepLooseEqual test_result, tests[test_name].expected, 'Meets expectations.'
            t.end()

            console.log '\n'
            inspect test_result

# Run all the tests
for test_name, test_data of tests
    runTest test_name

