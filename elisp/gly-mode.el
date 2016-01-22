(require 'generic-x)

(define-generic-mode
  'gly-mode             ;; name of the mode
  '()                   ;; comments delimiter
  '()                   ;; some keywords
  '(("\\\\\\(score\\|header\\|lyrics\\|l\\|music\\|markup\\|m\\)" . 'font-lock-keyword-face)
    ("\\(%.*\\)" 1 'font-lock-comment-face)
    ("^[a-z_\\-]+:" . 'font-lock-builtin-face) ;; header fields
    ("^.*--.*" . 'font-lock-type-face) ;; lyrics line
    )
  '("\\.gly$")          ;; files that trigger this mode
   nil                  ;; any other functions to call
  "Generic mode for GLY syntax highlighting" ;; doc string
)
