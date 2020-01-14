[![Build Status](https://travis-ci.org/igneus/gly.svg?branch=master)](https://travis-ci.org/igneus/gly)

# gly

Writer-friendly Gregorian notation format compiling to gabc.

One or more scores per file;
generate pdf preview without need to write a single line of LaTeX code;
write music and lyrics separately.

*GLY* is an acronym of "Gregorio for liLYponders" or
"Gregorio with separate LYrics.

## Why

One of the most popular solutions for typesetting square
notation used for the Gregorian chant is [Gregorio][gregorio].

Gregorio is a great tool, but I really don't like it's default
input format [gabc][gabc] - it's not very well readable,
pain to write, and too restrictive (for some reason doesn't
support other than the predefined header fields).
That led me to designing an alternative, Gregorio-inspired
notation format, which compiles to pure Gregorio gabc.

(Existence of the
[GABC Transcription Tool][bentrans] by Benjamin Bloomfield
suggests that the author of gly wasn't the only one who prefered
to enter music and lyrics separately.)

## Features

__gly language__
* music separated from lyrics
  * no need of the ubiquitous and tedious parentheses
  * music transcription is usually quicker and more comfortable
  * separation of "material and form" -> easy copying of the music or
    lyrics alone is possible (useful for a composer)
  * syllabified lyrics entered in a format inspired by LilyPond
* music and lyrics can be interspersed as needed
* no semicolons in the header
* custom header fields
* several scores per file

__gly tool__
* transform your gly document to one or more gabc scores
* compile pdf preview with a single command, without writing
  any (La)TeX
  * produces score annotations from provided score header fields
* transform gly document to (modern notation) lilypond document

## Real world examples

* [WIP Antiphonale according to the 1983 Ordo cantus officii][antiphonale83]
* [Proper Divine Office chants of Bohemian Premonstratensian houses][opraem_boh]

## Basic examples

Typical GABC source of an antiphon looks like this:

    name: Nativitas gloriosae;
    office-part: laudes, 1. ant.;
    occasion: In Nativitate B. Mariae Virginis;
    book: Antiphonale Romanum 1912, pg. 704;
    mode: 8;
    initial-style: 1;
    %%
    
    (c4) NA(g)TI(g)VI(g)TAS(gd) glo(f)ri(gh)ó(g)sae(g) * (,)
    Vír(g)gi(g)nis(hi) Ma(gh)rí(gf)ae,(f) (;)
    ex(f) sé(g)mi(h)ne(h) A(hiwji)bra(hg)hae,(g) (;)
    or(gh~)tae(g) de(g) tri(g)bu(fe/fgf) Ju(d)da,(d) (;)
    cla(df!gh)ra(g) ex(f) stir(hg~)pe(hi) Da(h)vid.(g) (::)

Corresponding GLY may look like this:

    \score
    name: Nativitas gloriosae
    office-part: laudes, 1. ant.
    occasion: In Nativitate B. Mariae Virginis
    book: Antiphonale Romanum 1912, pg. 704
    mode: 8
    initial-style: 1
    
    c4 g g g gd f gh g g ,
    g g hi gh gf f ;
    f g h h hiwji hg g ;
    gh~ g g g fe/fgf d d ;
    df!gh g f hg~ hi h g ::
    
    NA -- TI -- VI -- TAS glo -- ri -- ósae *
    Vír -- gi -- nis Ma -- rí -- ae,
    ex sé -- mi -- ne A -- bra -- hae,
    or -- tae de tri -- bu Ju -- da,
    cla -- ra ex stir -- pe Da -- vid.

Or, with music and lyrics interlaced
(this arrangement may be handy for larger scores,
like full-notated hymns, sequences or nocturnal responsories):

    \score
    name: Nativitas gloriosae
    office-part: laudes, 1. ant.
    occasion: In Nativitate B. Mariae Virginis
    book: Antiphonale Romanum 1912, pg. 704
    mode: 8
    initial-style: 1
    
    c4 g g g gd f gh g g ,
    NA -- TI -- VI -- TAS glo -- ri -- ósae *
    
    g g hi gh gf f ;
    Vír -- gi -- nis Ma -- rí -- ae,
    
    f g h h hiwji hg g ;
    ex sé -- mi -- ne A -- bra -- hae,
    
    gh~ g g g fe/fgf d d ;
    or -- tae de tri -- bu Ju -- da,
    
    df!gh g f hg~ hi h g ::
    cla -- ra ex stir -- pe Da -- vid.

Other arrangements are also possible. Order of music and lyrics
is actually ignored during processing.

## Syntax - Short Description

Score begins with a `\score` keyword.
Header fields follow. The header syntax is very similar to gabc,
except for semicolon at the end (omitted in gly) and the fact that
only one-line values are supported.
Unlike in gabc, there is no delimiter signaling end of the header.
Header ends with first line detected as music or lyrics.

Music lines contain only music. There is usually no need to enclose
music chunks in parentheses (the author's bias against writing
so many parentheses was one of the main motivations behind creating
gly), but you are allowed to write them if you want to.

Lyric lines contain lyrics, with syllables separated by double dash
`--` like in LilyPond.

For more detailed description of gly syntax see Syntax Reference below.

## Installation

Install Ruby (some 2.x version) runtime. Then install as any ruby gem:

`gem install gly`

If you plan to use `gly preview`,
ensure that you have a working installation of `gregorio` and
`lualatex`.

If you also plan to use the gly->lilypond translation,
install the [lygre][lygre] gem.
(This feature is currently only for the brave.
But better support is planned.)

## Usage

This gem provides executable `gly`. Run `gly help` for full list
of subcommands. The most important ones are:

`gly gabc FILE1 ...`

converts given gly file(s) to one or more gabc files (one per score,
i.e. one gly may spawn a bunch of gabcs).

`gly preview FILE1 ...`

creates a pdf document with all scores contained in each
gly file.

## Tools

[Emacs mode with syntax highlighting for gly][elisp]

![Editing gly in emacs](/doc/img/gly_emacs_scr.png)

## Syntax Reference

Gly syntax is line-based.
The interpreter reads the input line by line,
and depending on context it interprets each line as
e.g. music, lyrics or header field.

The syntax is quite permissive, not requiring a lot of delimiters
or hints for the parser concerning what each line means.
Mostly the parser guesses the meaning correctly.
Where not, meaning of each line can be stated explicitly.

### 1. Comments

When a `%` sign is encountered, everything until the end of line
is considered a comment and not interpreted.
(Comment syntax is the same as in gabc.)

Please note, that when compiling to gabc, comments are dropped
and don't appear in the resulting gabc file.

### 2. Whitespace

Empty lines are ignored.

### 3. Scores

A new score begins at the beginning of a file or at a line containing
a single keyword '\score'.

It consists of
a header (optional, only permitted at the beginning of a score)
and music- and lyrics-lines.
Lines with music and lyrics may appear in any order.

Score ends with end of file or with explicit beginning of a new score
or another top-level element.

#### 3.1 Score header

Score header starts at the beginning of the score and ends with
first non-empty line identified by the parser as music or lyrics.
Like in gabc it is optional - you aren't required to include header
in a score.

Header consists of fields.
Each header field is on it's own (one) line and consists of
identifier, colon and value:

    name: Nativitas gloriosae
    office-part: laudes, 1. ant.
    occasion: In Nativitate B. Mariae Virginis
    book: Antiphonale Romanum 1912, pg. 704
    mode: 8
    initial-style: 1

Header field identifier may only consist of alphanumeric characters,
minus-sign and underscore. Value can contain anything.

Header field 'id' is special: if present, it is used as suffix
of the generated gabc file (instead of the default, which is
numeric position of the score in the source document).

#### 3.2 Lyrics

Syntax of lyrics is inspired by LilyPond.
Lyrics have to be manually syllabified. Default syllable delimiter
is double dash (minus) `--` with optional whitespace around.

`cla -- ra ex stir -- pe Da -- vid.`

Underscore can be used to enter a "joining" space,
to set two or more words under a single note/neume.
Some languages, like Czech or Italian, use this feature.
The underscore will be replaced by a space in the gabc output.

`Pán s_vá -- mi.`

The parser guesses meaning of each line by attempting to find
syllable separator in it and by looking if it's alphanumeric
characters contain something that cannot be interpreted as music.
If any of these conditions is met, the line is interpreted as lyrics.

If gly fails to guess your lyrics line correctly and interprets
it as music, place `\lyrics` or it's shorter form `\l` at the beginning
of the unhappy line:

`\l a a a`

For the opposite case there is `\music` and it's shortcut `\m`.

`\m a[alt:když něco poplete autodetekci] j ivHG`

`\lyrics` or `\music` alone on it's own line starts a lyrics/music
block mode. It means that until the next block opening keyword
is encountered (`\lyrics`, `\music`, `\header`, `\score`),
default line meaning is lyrics/music.
Again, this is handy mostly when gly fails to guess your intentions.

In case you prefer another syllable separator over the default
double dash, there is a command line switch `--separator` or `-s`
for this purpose. However, setting a custom syllable separator
can have tricky consequences due to the way how gly guesses
meaning of lines.

#### 3.3 Music

Any line appearing in a score and not identified as header field
or lyrics is music by default.

Music line contains one or more music chunks separated by whitespace.
For music syntax see [official gabc documentation][gabc] -
gly doesn't change anything in this respect.

Music chunks may be enclosed in parentheses as in gabc.
That is especially useful in two cases:

* empty music chunk `()`
* music chunk containing space `(gf gf g!hi)`

#### 3.4 Matching lyrics to music

When processing the gly source and producing gabc, music chunks
are matched to lyric syllables.

There are, however, a few special cases, to make it work conveniently:

These special cases of music chunks don't get lyric syllable:

* clef
* music chunk containing only a division bar
  (eventually accompanied by a line break `z` or `Z`)

Exception to this rule are 'nonlyrical lyrics chunks'.
Currently there is only one built-in nonlyrical lyric chunk:
asterisk `*`.
Normally it is treated as any other syllable,
but if it meets a division, it is set as it's lyrics, while
a normal syllable wouldn't be.

If you need to set some other syllable under a division,
make it 'nonlyrical' by placing
an exclamation mark at it's beginning, e.g. `!<i>Ps.</i>`

In the other direction it is sometimes necessary to set a syllable
not matching any music at all. In such cases empty music chunk
`()` is what you need.

Explicit empty lyrics syllable can be produced by a lone exclamation
mark `!`. It is sometimes handy when `gly` doesn't recognize
a non-singable music chunk.

#### 3.5 Markup

Between scores (and only between scores) you can use
one-line

`\markup My annotation`

and block

```
\markup
My annotation
when I plan it long
```

markup. `gly preview` will insert the content of your
markups into the tex document it generates.
Markup is inserted as is - just with the `\markup` keyword +
leading and trailing whitespace stripped.
It means you can use TeX commands and other constructs
that make sense in a TeX document.

### 4. Document header

Each gly document may optinally contain a document header.
It may appear anywhere in the document, but best practice is to place
it at the very beginning.

Document header starts with keyword `\header` and ends
at the end of file or at the beginning of another top-level element.
The syntax of it's content is the same
as for score header.

    \header
    title: Hebdomada III Adventus

Field 'title' in the document header is, if present,
used by `gly preview` as title of the generated pdf.

## Customization

For quick transcription or composition the default output of
`gly preview` is possibly good enough. But what if you want to
customize the output? Switch font, fine-tune page geometry,
use custom headings? No problem! `gly` understands your desire
for beautiful music sheets.

The easiest way to customize the overall look-and-feel
of your `gly preview`s is a custom LaTeX template.

normally it would be a valid LaTeX document prepared for
gregorio (i.e. compatible with lualatex, importing
all the necessary packages) and containing two placeholders:

* `{{glyvars}}` in the preamble - it will be replaced by
  several LaTeX command definitions making available for you
  contents of the document header fields
* `{{body}}` in the document body - it is where
  scores will be inserted.

The double curly braces tell gly "this is a placeholder" -
the placeholder format is borrowed from popular templating
engines.

See the
[default template](lib/gly/templates/lualatex_document.tex)
for inspiration.

Render a preview with your fancy new template
by invoking

    gly preview -t TEMPLATE.tex DOCUMENT.gly

## How to run tests

execute `tests/run.rb`

## License

MIT

[gregorio]: http://gregorio-project.github.io
[gabc]: http://gregorio-project.github.io/gabc/index.html
[elisp]: /tree/master/elisp

[opraem_boh]: https://gist.github.com/igneus/1aed0b36e9b23b51526d
[antiphonale83]: https://github.com/igneus/antiphonale83

[bentrans]: https://bbloomf.github.io/jgabc/transcriber.html

[lygre]: https://github.com/igneus/lygre
