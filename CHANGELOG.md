# Changelog

## 0.0.4 (2016-06-18)

* gly fy: converts gabc to gly
* `\markup` keyword - verbatim text or LaTeX code to be included in the preview
* support gabc header field `nabc-lines` (don't comment it out in generated gabc)
* preview by default annotates scores by their `id` header value
* allow empty header fields
* block variant of `\lyrics` and `\music` keywords
* support for all gabc divisiones and hard line breaks (handled as "non-lyrical" music chunks)
* preview: format of placeholders in the document template changed to the django/jinja/... standard - e.g. `{{glyvars}}`
* tested documents containing adiastematic nabc notation
* preview: die loudly on error of the subordinate latex process
* preview: when input file doesn't exist, try to add extension - e.g. `gly preview hello` compiles `hello.gabc` if file `hello` doesn't exist

## 0.0.3 (2016-01-12)

* fix gly preview not regenerating once generated gabc files
* preview: optionally create non-standalone LaTeX document (for including in a larger one)
* preview: optionally include all document and score headers in the preview
* preview: support for custom document template
* option to set custom syllable separator
* if document contains a single score, don't add suffix to the generated gabc
* gly ly: limited support for conversion to lilypond
* `\music` keyword - explicit music line

## 0.0.2 (2015-12-16)

* preview: take `title` and `tagline` from document header
* preview: generate annotations from `annotation` score header fields
* gly list
* handles music chunk containing spaces (e.g. `(gh hg)`)

## 0.0.1

I'm not sure if 0.0.1 was released publicly and which features
it included.
