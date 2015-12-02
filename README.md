# gly

The friendly Gregorian notation format

## Why

For Gregorian notation there is no other software with such great
features as [Gregorio][gregorio].
However, it's input format, allowing only one score per file
and intermingling music with lyrics (thus making the lyrics
not-very-well-readable, preventing their easy copying etc.)
offends a programmer's eye (which desires separation of
content from logic, lyrics from music, ...)
and is further quite unpractical for a composer's workflows.

*gly* ("Gregorio for liLYponders" or "Gregorio with separate LYrics)
is basicly a modified Gregorio input format and a tool
which translates it to the standard clumsy GABC.

## Run tests

by executing `tests/run.rb`

## License

MIT

[gregorio]: https://github.com/gregorio-project/gregorio
