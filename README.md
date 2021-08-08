# micropress 🕹

**Micropress** isn't really a project per se -- I was looking into various techniques for [automatic text summarization](https://en.wikipedia.org/wiki/Automatic_summarization), and came up with a simple algorithm I wanted to implement myself that combined elements of existing approaches, and Micropress is just the algorithm that I came up with, in the form of an Ink library. The code you find here is an _extractive text summarization algorithm_: it tries to produce a good-enough summary of some source text by discovering a few representaative sentences from the larger text.

The algorithm estimates the "representativeness" of a given sentence in the rest of the text by computing how much of the significant tokens (words) in the given sentence is shared with the sentences in the rest of the text.

A very close variation of this algorithm is used for text summarization in [Revery](https://github.com/thesephist/revery).

## Demo

If you run `ink main.ink` in the repository, the demo script will generate a summary for `./sample.txt` which contains a verbatim copy of my blog post, ["Build tools around workflows, not workflows around tools"](https://thesephist.com/posts/tools/). The 1000-character summary it generates is:

>Build tools around workflows, not workflows around tools.
>
>While I was there, I thought a lot about tools – mechanical tools, software tools, tools that last, and tools that are fragile.  I want to share why I build my own tools and how I think we should think about building tools for life.  I don’t want to imply that my tools are objectively better than the professional tools on the market like Notion and Dropbox.  Good tools fit perfectly around our workflows, bad tools don’t.  Instead, to use these tools, we need to bend our workflows to fit around the tools.  The other benefit of building homebrew tools is that tools you build yourself can grow and change as your workflow changes over time.  This way, my tools can grow organically as my workflows evolve.  Own your load-bearing tools of life.  My productivity tools, especially my notes and contacts, are the load-bearing tools of my life.  How long do you expect these tools to work? Years? Decades?.  Since I’m the only user of these tools, most of my tools are gated behind HTTP basic auth and TLS.  Some tools have additional security layers.

