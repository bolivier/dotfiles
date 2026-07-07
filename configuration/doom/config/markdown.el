;;; ../../code/dotfiles/configuration/doom/config/markdown.el -*- lexical-binding: t; -*-

(defvar bso/current-line '(0 . 0)
  "(start . end) of current line in current buffer")
(make-variable-buffer-local 'bso/current-line)

(defun bso/unhide-current-line (limit)
  "Font-lock function"
  (let ((start (max (point) (car bso/current-line)))
        (end (min limit (cdr bso/current-line))))
    (when (< start end)
      (remove-text-properties start end
                              '(invisible t display "" composition ""))
      (goto-char limit)
      t)))

(defun bso/refontify-on-linemove ()
  "Post-command-hook"
  (let* ((start (line-beginning-position))
         (end (line-beginning-position 2))
         (needs-update (not (equal start (car bso/current-line)))))
    (setq bso/current-line (cons start end))
    (when needs-update
      (font-lock-fontify-block 3))))

(defun bso/markdown-unhighlight ()
  "Enable markdown concealling"
  (interactive)
  (markdown-toggle-markup-hiding 'toggle)
  (font-lock-add-keywords nil '((bso/unhide-current-line)) t)
  (add-hook 'post-command-hook #'bso/refontify-on-linemove nil t))


(add-hook 'markdown-mode-hook #'bso/markdown-unhighlight)

(use-package markdown-mode
  :commands gfm-mode markdown-mode
  :mode
  ("README\\.md\\'" . gfm-mode)
  ("\\.md\\'" . markdown-mode)
  ("\\.markdown\\'" . markdown-mode)
  :custom
  (markdown-header-scaling t)
  (markdown-hide-urls t)
  (markdown-fontify-code-blocks-natively t) )

;; I think this was causing issues
(custom-set-faces!
  '(markdown-header-delimiter-face :foreground "#616161" :height 0.9)
  '(markdown-header-face-1 :height 1.8 :foreground "#A3BE8C" :weight extra-bold :inherit markdown-header-face)
  '(markdown-header-face-2 :height 1.4 :foreground "#EBCB8B" :weight extra-bold :inherit markdown-header-face)
  '(markdown-header-face-3 :height 1.2 :foreground "#D08770" :weight extra-bold :inherit markdown-header-face)
  '(markdown-header-face-4 :height 1.15 :foreground "#BF616A" :weight bold :inherit markdown-header-face)
  '(markdown-header-face-5 :height 1.1 :foreground "#b48ead" :weight bold :inherit markdown-header-face)
  '(markdown-header-face-6 :height 1.05 :foreground "#5e81ac" :weight semi-bold :inherit markdown-header-face))




