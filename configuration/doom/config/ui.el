;;; ../../code/dotfiles/configuration/doom/config/ui.el -*- lexical-binding: t; -*-



;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!sd

(setq coding-font (cl-find-if (lambda (f)
				(find-font (font-spec :name f)))
			      '("0xProto"
                                "Comic Code"
				"Fira Code")))

(setq doom-font                (font-spec :family coding-font :size 13)
      doom-variable-pitch-font (font-spec :family coding-font ) ; inherits `doom-font''s :size
      doom-symbol-font         (font-spec :family "Noto Color Emoji" :size 13)
      doom-big-font            (font-spec :family coding-font :size 18)
      doom-font-increment      1)

;; Emoji fix
(set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji") nil 'prepend)
(set-fontset-font t 'unicode (font-spec :family "Symbols Nerd Font Mono") nil 'append)

(setq doom-theme 'modus-operandi)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 't)
(setq-default display-line-numbers-type 't)

(use-package! auto-dark  
  :init
  ;; Configure themes
  (setopt auto-dark-themes '((modus-vivendi) (modus-operandi)))
  ;; Disable doom's theme loading mechanism (just to make sure)
  (setopt doom-theme nil)
  
  ;; Enable auto-dark-mode at the right point in time.
  ;; This is inspired by doom-ui.el. Using server-after-make-frame-hook avoids
  ;; issues with an early start of the emacs daemon using systemd, which causes
  ;; problems with the DBus connection that auto-dark mode relies upon.
  (defun my-auto-dark-init-h ()
    (auto-dark-mode)
    (remove-hook 'server-after-make-frame-hook #'my-auto-dark-init-h)
    (remove-hook 'after-init-hook #'my-auto-dark-init-h))
  (let ((hook (if (daemonp)
                  'server-after-make-frame-hook
                'after-init-hook)))
    ;; Depth -95 puts this before doom-init-theme-h, which sounds like a good
    ;; idea, if only for performance reasons.
    (add-hook hook #'my-auto-dark-init-h -95)))
