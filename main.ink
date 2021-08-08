std := load('vendor/std')
str := load('vendor/str')

log := std.log
readFile := std.readFile

summarize := load('lib/micropress').summarize

readFile('./sample.txt', file => file :: {
	() -> log('could not read file')
	_ -> log(summarize(file, 1000))
})

