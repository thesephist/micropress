` micropress is a simple automatic text summarization library.

It exposes a single function, micropress.summarize(), that tries to rank and
identify the most salient and "central" N sentences in the text, and stitch
them together to create a "summary" of the original text at a fraction of the
length. `

std := load('../vendor/std')
str := load('../vendor/str')
quicksort := load('../vendor/quicksort')

log := std.log
f := std.format
cat := std.cat
slice := std.slice
map := std.map
each := std.each
reduce := std.reduce
filter := std.filter
flatten := std.flatten
lower := str.lower
upper := str.upper
split := str.split
replace := str.replace
trimSuffix := str.trimSuffix
trim := str.trim
sortBy := quicksort.sortBy

tokenize := load('../vendor/tokenizer').tokenize

Newline := char(10)

tokensIntersectionScore := (tok1, tok2) => (
	keys1 := keys(tok1)
	len1 := reduce(keys1, (sum, k) => sum + tok1.(k), 0)
	len2 := reduce(keys(tok2), (sum, k) => sum + tok2.(k), 0)

	reduce(keys1, (acc, key) => tok2.(key) :: {
		() -> acc
		_ -> tok1.(key) + tok2.(key)
	}, 0) / (len1 + len2 + 1)
)

upcaseFirstLetter := s => s.0 := upper(s.0)

stripTransition := sent => lower(slice(sent, 0, 4)) :: {
	'and ' -> upcaseFirstLetter(slice(sent, 4, len(sent)))
	'but ' -> upcaseFirstLetter(slice(sent, 4, len(sent)))
	'and,' -> upcaseFirstLetter(slice(sent, 5, len(sent)))
	'but,' -> upcaseFirstLetter(slice(sent, 5, len(sent)))
	_ -> sent
}

summarize := (text, maxChars) => (
	paragraphs := filter(split(text, Newline), s => len(s) > 0)
	paragraphSentences := map(paragraphs, para => split(para, '. '))

	allSentences := map(filter(flatten(paragraphSentences), s => len(s) > 0), sent => trimSuffix(sent, '.'))
	sentenceOrder := reduce(allSentences, (acc, sent, i) => acc.(sent) := i, {})
	allTokens := map(allSentences, tokenize)

	` lower rank == more central sentence `
	ranks := reduce(allSentences, (ranks, sent, i) => (
		tokens := allTokens.(i)
		ranks.(sent) := reduce(allTokens, (sum, other) => sum - tokensIntersectionScore(tokens, other), 0)
	), {})

	sortBy(allSentences, sent => ranks.(sent))
	summarySentences := (sub := (acc, chars, i) => chars > maxChars | allSentences.(i) = () :: {
		true -> acc
		_ -> sub(acc.len(acc) := allSentences.(i), chars + len(allSentences.(i)), i + 1)
	})([], 0, 0)
	sortBy(summarySentences, sent => sentenceOrder.(sent))
	summarySentences := map(summarySentences, stripTransition)
	cat(map(summarySentences, sent => sent + '.'), Newline)
)

