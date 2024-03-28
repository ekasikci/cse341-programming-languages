(defvar *input-stream* nil)
(defvar *comment-flag* 0)

(defun gppinterpreter(&optional filename)
  (if filename
      (setq *input-stream* (open filename :if-does-not-exist nil)))
  (main-loop)
)

(defun main-loop()
  (setq line (get-line))
  (if (eq line nil)
      (return-from main-loop 0))
  (setq ret-value (process-line line))
  (if (or (string= ret-value "SYNTAX_ERROR") (string= ret-value "KW_EXIT"))
      (return-from main-loop 1)
  )
  (if (eq *input-stream* nil)
      (terpri))
  (main-loop)
)

(defun get-line()
  (if (eq *input-stream* nil)
      (return-from get-line (read-line))
      (return-from get-line (read-line *input-stream* nil))
  )
)

(defun process-line(line)
  (setq line (concatenate 'string line (list #\newline)))
  (let ((current-token ""))
  (loop for i from 1 to (length line)
        do (
           setq current-token 
           (process-token current-token line i ))
        do (
           if (or (string= current-token "SYNTAX_ERROR") (string= current-token "KW_EXIT"))
           (return-from process-line current-token)
           )
  ))
)

(defun is-number (first-char)
  (if (and (char>= first-char #\0) (char<= first-char #\9))
      1
      0))

(defun process-token(token line i)
  (setq current-char (char line (- i 1)))
  
  (if 
      (not
       (or 
        (char= current-char #\newline)
        (char= current-char #\space)
        (char= current-char #\tab)
        )
       )
      (setq token (concatenate 'string token (list current-char)))
      )

  ; If the current character is newline, we set the comment flag to 0
  (if (char= current-char #\newline)
      (setq *comment-flag* 0)
  )

  ; Return the token if it is empty
  (if (string= token "")
      (return-from process-token token)
      )

  ; send the token to the build-token if it's not a comment
  (if (= *comment-flag* 0)
      (setq token (build-token token line i))
      (setq token "")
  )

  (return-from process-token token)
)

(defun build-token(token line i)
  (setq check-result (dfa token line i))

  ; If nothing is found and there was no SYNTAX_ERROR, continue building the token
  (if (string= check-result "")
      (return-from build-token token)
      )

  ; Syntax error found
  (if (string= check-result "SYNTAX_ERROR")
      (return-from build-token "SYNTAX_ERROR")
      )

  ; Exit keyword found
  (if (string= check-result "KW_EXIT")
      (return-from build-token "KW_EXIT")
      )

  ; Previous token was processed; return an empty token to continue
  (return-from build-token "")
)

(defun dfa(token line i)
  ; Check if it's an operator
  (setq is-operator-result (is-operator token line i))

  ; If it's an operator, return the token itself
  (if (not (string= is-operator-result ""))
      (return-from dfa (print-and-return is-operator-result))
      )

  ; check if the token is completed
  (setq next-operator (is-token-completed line i))

  ; If none of those characters are near, return the token itself for further construction
  (if (= next-operator 0)
      (return-from dfa "")
      )

  ; Check for keywords
  (setq check (is-keyword token))

  (if (not (string= check ""))
      (return-from dfa (print-and-return check))
      )


  ; analyze the token for valuef, identifier or syntax error
  (setq dfa-helper-return (dfa-helper token))

  (if (string= dfa-helper-return "SYNTAX_ERROR")
      (progn
        (terpri)
        (format t dfa-helper-return)
        (format t " ")
        (format t token)
        (format t " ")
        (format t "cannot be tokenized")
        )
      (print-and-return dfa-helper-return)
      )

  ; Return the value
  (return-from dfa dfa-helper-return)
)

(defun dfa-helper(token)
  (setq valuef 0)
  (setq identifier 0)

  ; Go character by character

  ; Set the current DFA input and check it in this state
  (setq first-char (char token 0))

  ; If the first character is a number, all of them have to be numbers
  (if (= (is-number first-char) 1)
      (setq valuef (is-valuef token))
  )

  ; If the first character is a letter, all others are either letters or digits
  (if (= (is-letter first-char) 1)
      (setq identifier (is-letter-or-number token))
  )

  ; If SYNTAX_ERROR, both valuef and identifier are 0
  (if (= valuef 1)
      (return-from dfa-helper "VALUEF")
  )
  (if (= identifier 1)
      (return-from dfa-helper "IDENTIFIER")
  )
  (return-from dfa-helper "SYNTAX_ERROR")
)

(defun is-letter(first-char)
  (if (or (and (char>= first-char #\a)(char<= first-char #\z))(and (char>= first-char #\A)(char<= first-char #\Z)))
      (return-from is-letter 1)
      (return-from is-letter 0)
  )
)

(defun is-letter-or-number(token)
  (loop for i from 0 to (- (length token) 1)
        do (if
           (not 
            (or 
             (= (is-number (char token i) ) 1)
             (= (is-letter (char token i) ) 1)
            )
           )
           (return-from is-letter-or-number 0)
        )
  (return-from is-letter-or-number 1)
  )
)

(defun is-number(first-char)
  (if (and (char>= first-char #\0)(char<= first-char #\9))
      (return-from is-number 1)
      (return-from is-number 0)
  )
)
(defun is-valuef(token)
  (loop for i from 0 to (- (length token) 1)
        do
        (if (not (is-number (char token i)))
            (return-from is-valuef 0))
        (if (char= (char token i) #\b)
            (loop for j from (+ i 1) to (- (length token) 1)
                  do
                  (if (char= (char token (+ i 1)) #\0)
                      (return-from is-valuef 0))
                  (if (not (is-number (char token j)))
                      (return-from is-valuef 0))
                  finally (return-from is-valuef 1))
        )
        finally (return-from is-valuef 1)
  )
)
        
(defun print-and-return(token)
  (print (read-from-string token))
  (return-from print-and-return token)
)

(defun is-token-completed(line i)
  (if (and (< i (length line)) (= (check-char line i) 1))
      (return-from is-token-completed 1)
      )
  (return-from is-token-completed 0)
)

(defun check-char (line i)
  (let ((current-char (char line i)))
    (cond
      ((find current-char '(#\+ #\- #\/ #\* #\( #\) #\" #\, #\; #\newline #\tab #\space) :test #'char=) 1)
      (t 0))))


(defun is-operator(token line i)
  (cond
   ((string= token "+") "OP_PLUS")
   ((string= token "-") "OP_MINUS")
   ((string= token "/") "OP_DIV")
   ((string= token "*") "OP_MULT")
   ((string= token "(") "OP_OP")
   ((string= token ")") "OP_CP")
   ((string= token ",") "OP_COMMA")
   ((string= token ";") (is-comment line i))
   (t "")
  )
)
(defun is-keyword(token)
  (let ((keywords '("and" "or" "not" "equal" "less" "nil" "list" "append" "concat" "set" "def" "for" "if" "exit" "load" "display" "true" "false")))
    (if (string= token (car (remove-if-not (lambda (kw) (string= token kw)) keywords)))
        (string-upcase (concatenate 'string "KW_" token))
        "")))

(defun is-comment(line i)
  (if (and (< i (length line)) (char= #\; (char line i)))
      (return-from is-comment (set-comment))
  )
  (return-from is-comment "")
)

(defun set-comment()
  (setq *comment-flag* 1)
  (return-from set-comment "COMMENT")
)

; Starting the custom interpreter
(if (equal *args* nil)
    (gppinterpreter)
    (gppinterpreter (first *args*))
)
