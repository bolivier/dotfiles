(defun winnow-results-start ()
  "Find the start position of the compilation output."
  (save-excursion
    (goto-char (point-min))
    (when (derived-mode-p 'compilation-mode)
      (compilation-next-error 1))
    (line-beginning-position 1)))

(defun winnow-results-end ()
  "Find the end position of the compilation output."
  (save-excursion
    (goto-char (point-max))
    (when (derived-mode-p 'compilation-mode)
      (compilation-next-error -1))
    (line-beginning-position 2)))

(defun winnow-exclude-lines (regexp &optional rstart rend interactive)
  "Exclude the REGEXP matching lines from the compilation results.

Ignores read-only-buffer to exclude lines from a result.

See `flush-lines' for additional details about arguments REGEXP,
RSTART, REND, INTERACTIVE."
  (interactive (keep-lines-read-args "Flush lines containing match for regexp"))
  (let ((inhibit-read-only t)
        (start (or rstart (winnow-results-start)))
        (end (or rend (winnow-results-end))))
    (flush-lines regexp start end interactive)
    (goto-char (point-min))))

(defun winnow-match-lines (regexp &optional rstart rend interactive)
  "Limit the compilation results to the lines matching REGEXP.

Ignores read-only-buffer to focus on matching lines from a
result.

See `keep-lines' for additional details about arguments REGEXP,
RSTART, REND, INTERACTIVE."
  (interactive (keep-lines-read-args "Keep lines containing match for regexp"))
  (let ((inhibit-read-only t)
        (start (or rstart (winnow-results-start)))
        (end (or rend (winnow-results-end))))
    (keep-lines regexp start end interactive)
    (goto-char (point-min))))

(map! :map grep-mode-map
      "x" #'winnow-exclude-lines
      "m" #'winnow-match-lines)

