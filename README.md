# gly

Writer-friendly Gregorian notation format compiling to gabc.

*GLY* is an acronym of "Gregorio for liLYponders" or
"Gregorio with separate LYrics.

## Why

One of the most popular solutions for typesetting quadratic
notation used for the Gregorian chant is [Gregorio][gregorio].

However, I have several objections against it's input format.
That led me to designing an alternative, Gregorio-inspired
notation format, which compiles to pure Gregorio GABC
(which I don't like writing manually).

## Features

* music separated from lyrics
  * no need of the ubiquitous and tedious parentheses
  * separation of "material and form" -> easy copying of the music or
    lyrics alone is possible (useful for a composer)
  * syllabified lyrics entered in a format inspired by LilyPond
* music and lyrics can be interspersed as needed
* no semicolons in the header
* custom header fields supported (commented out in the GABC output;
  as gregorio crashes on headers it doesn't know)
* several scores per file (when compiled to gabc, each becomes
  a separate file)
* compile pdf preview by a single command, without writing any (La)TeX

## Examples

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

Or, with music and lyrics interlaced:

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

## Usage

This gem provides executable `gly`. Run `gly help` for full list
of subcommands. The most important ones are:

`gly gabc FILE1 ...`

converts given gly file(s) to one or more gabc files (one per score,
i.e. one gly may spawn a bunch of gabcs).

`gly preview FILE1 ...`

Attempts to create a pdf document with all scores contained in each
gly file. Expects gregorio and lualatex to be in PATH
and gregoriotex to be installed and accessible by lualatex.

## Tools

[Emacs mode with syntax highlighting for gly][elisp]

![Editing gly in emacs](/doc/img/gly_emacs_scr.png)

## Run tests

by executing `tests/run.rb`

## License

MIT

[gregorio]: https://github.com/gregorio-project/gregorio
[elisp]: /tree/master/elisp
