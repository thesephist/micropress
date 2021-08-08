` micropress is a simple automatic text summarization library.

It exposes a single function, micropress.summarize(), that tries to rank and
identify the most salient and "central" sentences in the text, and stitch
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

	` very short sentences should simply not be considered `
	len1 < 4 | len2 < 4 :: {
		true -> 0
		_ -> reduce(keys1, (acc, key) => tok2.(key) :: {
			() -> acc
			_ -> tok1.(key) + tok2.(key)
		}, 0) / (len1 + len2 + 1)
	}
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
	` split source text into a list of sentences `
	paragraphs := filter(split(text, Newline), s => len(s) > 0)
	paragraphSentences := map(paragraphs, para => split(para, '. '))
	allSentences := map(filter(flatten(paragraphSentences), s => len(s) > 0), sent => trimSuffix(sent, '.'))

	` original sentence order is used to restore order in result `
	sentenceOrder := reduce(allSentences, (acc, sent, i) => acc.(sent) := i, {})
	` map sentences to their token lists `
	allTokens := map(allSentences, tokenize)

	` map all sentences to their scores, where a score is the sum of word
	similarity (token intersections) between a given sentence and all other
	sentences in the text. `
	ranks := reduce(allSentences, (ranks, sent, i) => (
		tokens := allTokens.(i)
		ranks.(sent) := reduce(allTokens, (sum, other) => sum - tokensIntersectionScore(tokens, other), 0)
	), {})
	` sort all sentences by their score `
	sortBy(allSentences, sent => ranks.(sent))

	` get top N sentences such that we approximate requested maxChars `
	summarySentences := (sub := (acc, chars, i) => chars > maxChars | allSentences.(i) = () :: {
		true -> acc
		_ -> sub(acc.len(acc) := allSentences.(i), chars + len(allSentences.(i)), i + 1)
	})([], 0, 0)
	` re-order sentences by their original order in source text `
	sortBy(summarySentences, sent => sentenceOrder.(sent))

	` construct final result `
	summarySentences := map(summarySentences, stripTransition)
	cat(map(summarySentences, sent => sent + '.'), Newline)
)

