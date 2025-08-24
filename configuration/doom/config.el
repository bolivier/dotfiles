(defmacro comment (&rest args)
  nil)
(setq mac-control-modifier 'control)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier  'super)
(setq ns-function-modifier 'hyper)

;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

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
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-tokyo-night)

(setq! datetime-timezone 'US/Central)

(setq doom-font                (font-spec :family "Comic Code" :size 14)
      doom-variable-pitch-font (font-spec :family "Comic Code") ; inherits `doom-font''s :size
      doom-symbol-font         (font-spec :family "Noto Color Emoji" :size 14)
      doom-big-font            (font-spec :family "Comic Code" :size 16)
      doom-font-increment      1)

;; Emoji fix
(set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji") nil 'prepend)
(set-fontset-font t 'unicode (font-spec :family "Symbols Nerd Font Mono") nil 'append)


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)
;; (add-hook! prog-mode display-line-numbers-mode)


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(use-package! org
  :init
  (add-hook! org-mode-hook #'auto-fill-mode))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).

(defun switch-to-or-create-postgres-buffer ()
  (interactive)
  (if-let ((buffer (get-buffer "*SQL: Postgres*")))
      (switch-to-buffer buffer)
    (sql-postgres)))

;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(use-package! emacs
  :config
  (setq work-dir "/Users/brandon/work")
  (setq tab-always-indent t)
  (map! "C-r"     #'isearch-backward-regexp
        "C-s"     #'isearch-forward-regexp
        "C-x C-b" #'ibuffer
        "C-x g"   #'goto-line
        "C-x k"   (lambda () (interactive) (kill-this-buffer))
        "C-x ="   #'balance-windows
        "M-%"     #'query-replace-regexp
        "M-["     #'pop-global-mark
        "M-i"     #'imenu
        "M-z"     #'zap-up-to-char
        "M-Z"     #'zap-to-char
        "s-f"     #'find-files
        :n "C-SPC" #'company-complete-common
        :leader :prefix "o"
        "d" #'switch-to-or-create-postgres-buffer))

(after! company
  ;; delay time for company doing auto complete. I usually like to NOT have that
  ;; pop up while I'm thinking. This is a guess for a good length, but it's
  ;; pretty long. It was at something like 0.2 before this.
  (setq company-idle-delay 2))

(after! evil
  ;; kj won't work without this
  (evil-escape-mode)

  (map!
   :i "C-w j" #'evil-window-down
   :i "C-w k" #'evil-window-up
   :i "C-w h" #'evil-window-left
   :i "C-w l" #'evil-window-right)

  (map!
   :after vterm
   :map vterm-mode-map
   "C-h" #'evil-window-left
   "C-j" #'evil-window-down
   "C-k" #'evil-window-up
   "C-l" #'evil-window-right))

(after! evil-escape
  (setq evil-escape-key-sequence "kj"))

(after! evil-snipe
  (setq! evil-snipe-scope 'visible))

(defun save-all () (save-some-buffers t))
(add-hook! focus-out #'save-all)

(use-package! better-jumper
  :config
  (defun bso-advice/set-jump! (&rest args)
    "Sets a jump point ignoring all args."
    (better-jumper-set-jump))

  ;; These aren't setting the jump by default.
  ;; Custom fn
  (advice-add '+lookup/definition :before #'bso-advice/set-jump!)
  (advice-add '+lookup/type-definition :before #'bso-advice/set-jump!))

(defun bso/log-copied-var-here ()
  (interactive)
  (save-excursion
    (insert "console.log(")
    (yank)
    (insert ")")))

(use-package! avy
  :init
  (setq! avy-all-windows t)
  (define-key!
    "C-." #'avy-goto-char-timer))

(use-package! magit
  :init
  (map! "C-c g b"   #'magit-blame
                                        ; "C-c g g"   #'magit-status ;; moving to jj
        "C-c g n" #'+vc-gutter/next-hunk
        "C-c g p" #'+vc-gutter/previous-hunk
        "C-c g r" #'+vc-gutter/revert-hunk))

(use-package! jj-mode
  :init
  (map!
   "C-c g g" #'jj-log))

(after! paredit
  (map! :mode emacs-lisp-mode
        "C-c C-c" #'eros-eval-defun)
  (add-hook! (emacs-lisp-mode lisp-interaction-mode) 'enable-paredit-mode)

  (defun bso/evil-change-line-in-paredit ()
    "Use `paredit-kill' then change into insert mode. Basically just a
smarter version of the regular behavior"
    (interactive)
    (paredit-kill)
    (evil-insert 1)))

(use-package! ace-window
  :defer nil
  :config
  (setq!  aw-scope 'frame
          aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))

  (map! "M-o"     #'ace-window
        "C-x o"  #'ace-window))

(add-to-list '+file-templates-alist '("\\.test\\.tsx?"
                                      :mode typescript-tsx-mode
                                      :trigger "__test.js"))

(after! projectile
  (map!
   :map projectile-mode-map
   "M-O" #'projectile-find-file
   "M-F" #'+default/search-project

   :leader :prefix "p"
   :n "t" #'projectile-toggle-between-implementation-and-test))

(after! org
  (add-to-list 'org-capture-templates
               '("E" "Emacs" entry
                 (file (concat org-directory "Emacs.org"))
                 "* TODO %?" :empty-lines 1)))

(use-package! lsp-mode
  :init
  (setq lsp-file-watch-threshold 5000)
  (require 'lsp)
  (lsp-make-interactive-code-action organize-imports-ts "source.organizeImports.ts-ls")
  (lsp-make-interactive-code-action remove-unused-imports "source.removeUnusedImports")

  (defun bso/lsp-organize-and-remove-imports ()
    (interactive)
    (lsp-organize-imports-ts)
    (lsp-remove-unused-imports))

  (map! :map general-override-mode-map
        :leader
        :prefix "c"
        "o" #'lsp-organize-imports)

  :config
  (require 'lsp-ui)
  (lsp-ui-doc-mode 1)
  (setq lsp-ui-doc-position 'top)
  (setq lsp-ui-doc-show-with-cursor 't))

(use-package sql
  :init
  (add-hook! sql-mode-hook (lambda ()
                             (company-mode -1))))

(use-package! typescript-mode
  :config
  (defun bso/toggle-js-async-fn ()
    "Toggle between async and non async JS functions.

Calls sp-backwards-up-sexp until at what looks like a JS function
and them either inserts `async' or deletes it.

The implementation is kinda sloppy, but it works fine for now.

I limited nesting to 10, if that's too few, I can implement by
checking the last known position of the point.'"
    (interactive)
    (cl-flet* ((looking-at-js-function? (lambda ()
                                          (or
                                           (looking-back "=> ")

                                           (save-excursion
                                             (backward-word 3)
                                             (looking-at "function"))

                                           (save-excursion
                                             (backward-word 3)
                                             (looking-at "function")))))

               (move-to-anon-fn-init (lambda ()
                                       (sp-backward-sexp 1)
                                       (unless (looking-at "(")
                                         (web-mode-backward-sexp 1))))

               (move-to-function-fn-init (lambda ()
                                           (sp-backward-sexp 3)
                                           (unless (looking-at "function")
                                             (web-mode-backward-sexp 1))))

               (move-to-fn-init (lambda ()
                                  (if (looking-back "=> ")
                                      (move-to-anon-fn-init)
                                    (move-to-function-fn-init)))))
      (save-excursion
        (let* ((i 0))
          (while (and (not (looking-at-js-function?))
                      (< i 10))
            (setq i (+ 1 i))
            (sp-backward-up-sexp))
          (move-to-fn-init))
        (if (save-excursion
              (backward-word 1)
              (looking-at
               (rx "async " anychar)))
            (progn
              (backward-word 1)
              (kill-word 1)
              (if (looking-at " function")
                  (delete-horizontal-space)
                (just-one-space)))
          (insert "async ")))))

  (add-hook! (typescript-tsx-mode typescript-mode rjsx-mode)
             'prettier-mode
             'turn-on-smartparens-strict-mode
             (emmet-mode -1))
  (map! :map (typescript-mode typescript-tsx-mode-map
                              js2-mode)
        "C-c c f" #'bso/toggle-js-async-fn)


  (map! :map general-override-mode-map
        "C-c c f" nil)
  )

(defun +web/indent-or-yas-or-emmet-expand ()
  "Do-what-I-mean on TAB.

Invokes `indent-for-tab-command' if at or before text bol, `yas-expand' if on a
snippet, or `emmet-expand-yas'/`emmet-expand-line', depending on whether
`yas-minor-mode' is enabled or not."
  (interactive)
  (call-interactively
   (cond ((or (<= (current-column) (current-indentation))
              (not (eolp))
              (not (or (memq (char-after) (list ?\n ?\s ?\t))
                       (eobp))))
          #'indent-for-tab-command)
         ((yas--templates-for-key-at-point)
          #'yas-expand)

         #'emmet-expand-yas)))

(use-package! rjsx-mode
  :init
  (add-hook! rjsx-mode 'prettier-mode
    (emmet-mode -1)))

(use-package! json-mode
  :init
  (add-hook! json-mode 'prettier-mode))

(use-package! prodigy
  :defer nil
  :init
  (defun prodigy-set-tag-filter ()
    "Read tag and add filter so that only services with that tag show."
    (interactive)
    (prodigy-with-refresh
     (let ((tag (prodigy-read-tag)))
       (prodigy-clear-filters)
       (prodigy-add-filter :tag tag))))

  ;; define services in other files and load them here. Do not track in vcs.

  (define-key!
    "C-c o p" #'prodigy))

(use-package! smartparens
  :init
  (map!
   :map smartparens-mode-map
   "M-s" 'sp-splice-sexp
   "C-M-u" #'sp-backward-up-sexp
   "C-<right>" #'sp-slurp-hybrid-sexp
   "C-<left>" #'sp-forward-barf-sexp))

(use-package! apheleia
  :config
  (setf (alist-get 'zprint apheleia-formatters)
        '("zprint")))

(after! (apheleia clojure)
  (defun disable-apheleia-for-edn ()
    (when (and buffer-file-name
               (string-equal (file-name-extension buffer-file-name) "edn"))
      (apheleia-mode -1)))
  (add-hook 'clojure-mode-hook #'disable-apheleia-for-edn)


  (setf (alist-get 'clojure-mode apheleia-mode-alist) 'zprint
        (alist-get 'clojure-ts-mode apheleia-mode-alist) 'zprint))
;; Clojure
(use-package! cider
  :config
  
  (defun clojure-project-root-path (&optional dir-name)
    "Overridden by me in the config.

Return the absolute path to the project's root directory.

Use `default-directory' if DIR-NAME is nil.
Return nil if not inside a project."
    (let* ((dir-name (or dir-name default-directory))
           (choices (delq nil
                          (mapcar (lambda (fname)
                                    (locate-dominating-file dir-name fname))
                                  clojure-build-tool-files))))
      (when (> (length choices) 0)
        (car (sort choices)))))

  (setq-default cider-clojure-cli-aliases ":dev:test")
  (setq cider-clojure-cli-aliases ":dev:test")

  (add-hook! clojure-mode
             'turn-off-smartparens-strict-mode
             'turn-off-smartparens-mode
             'enable-paredit-mode)
  (defun bso/cider-restart ()
    (interactive)
    (save-some-buffers t)
    (cider-interactive-eval
     "(ns user) (require '[integrant.repl :as ir]) (ir/reset)"))

  (defun bso/cider-inside-let-p ()
    "Check if I'm immediately inside a let binding"
    (interactive)
    (condition-case err
        (save-excursion
          (paredit-backward-up 2)
          (looking-at "(let"))
      (error nil)))

  (defun bso/cider-def-var ()
    "Read the previous sexp and define it as (def NAME <sexp>) in Clojure using CIDER."
    (interactive)
    (save-excursion
      (let ((sexp (progn
                    (backward-sexp)
                    (thing-at-point 'sexp t)))
            (name (if (bso/cider-inside-let-p)
                      (progn
                        (backward-sexp)
                        (thing-at-point 'symbol))
                    (read-string "Var name: ")
                    )))
        (cider-interactive-eval
         (format "(def %s %s)" name sexp)))))

  (map! :map cider-mode-map

        "C-c l e v" #'bso/cider-def-var

        :map clojure-mode-map
        "C-c C-r s e" #'cljr-expand-let
        "C-c C-r U" #'clojure-unwind-all)

  ;; Keeps perf good
  (setq! clojure-toplevel-inside-comment-form t)

  (defun save-clojure-buffer (&rest x)
    (save-buffer 0))

  (advice-add 'cider-eval-buffer :before #'save-clojure-buffer)
  (after! evil
    ;; these don't work that well.

    (defun evil-cider-update-cursor-for-eval (f &rest args)
      (interactive)
      (unless (eq evil-state 'normal)
        (funcall f args)
        (cond ((looking-at ")") (save-excursion
                                  (evil-save-state
                                   (evil-emacs-state)
                                   (forward-char 1)
                                   (funcall f args))))
              ((looking-at "(") (save-excursion
                                  (evil-save-state
                                   (evil-emacs-state)
                                   (paredit-forward)
                                   (funcall f args)))))))

    (advice-add 'cider-eval-last-sexp :around #'evil-cider-update-cursor-for-eval)
    (advice-add 'cider-pprint-eval-last-sexp :around #'evil-cider-update-cursor-for-eval))

  (defun bso-cider/conditional-eval ()
    "Evaluate the region as elisp when the region is active.
Alternately eval the last sexp if the char before point is `)'.
Otherwise move forward sentence, like normal"
    (interactive)
    (let ((beg (mark))
          (end (point)))
      (save-excursion
        (cond
         ((use-region-p) (cider-eval-region beg end))
         ((looking-at (rx (any "({["))) (paredit-forward) (cider-eval-last-sexp nil))

         ((looking-back (rx (any "]})"))) (cider-eval-last-sexp nil))
         (t (message "Could not find anything to eval."))))))

  (map!
   :map paredit-mode-map
   "M-<backspace>" 'paredit-backward-kill-word
   "d" 'self-insert-command
   "DEL" 'paredit-backward-delete
   :n ">" #'paredit-forward-slurp-sexp
   :n "<" #'paredit-forward-barf-sexp
   :nv "D" #'paredit-kill

   (:map cider-mode-map
    :leader :prefix "me"
    :n "f" #'cider-eval-defun-at-point
    :n "v" #'cider-eval-last-sexp-in-context
    :n "p" #'cider-pprint-eval-last-sexp
    :n "P" #'cider-eval-last-sexp-and-replace)

   :mode cider-repl-mode
   "<up>"   #'cider-repl-previous-input
   "<down>" #'cider-repl-next-input
   "C-c o"  #'cider-repl-clear-buffer

   :map cider-mode-map
   "<f4>" #'bso/cider-restart
   "M-e" #'bso-cider/conditional-eval
   "M-E" #'cider-eval-buffer

   :leader :prefix "l"
   "e a" #'bso/cider-restart)

  (defun skip-to-closing-if-at-opening (f &rest args)
    (save-excursion
      (when (looking-at (rx (any "({[")))
        (paredit-forward))
      (apply f args)))

  (advice-add 'cider-pprint-eval-last-sexp :around #'skip-to-closing-if-at-opening)

  (defun my/cider-show-result-in-cider-result-buffer (value)
    "Show eval result VALUE in *cider-result*, replacing its contents."
    (when (get-buffer-window "*cider-result*")
      (let ((buf (get-buffer-create "*cider-result*")))
        (with-current-buffer buf
          (let ((inhibit-read-only t))
            (erase-buffer)
            (insert value)
            (goto-char (point-min))))
        ;; (display-buffer buf)
        )))

  (defun my/cider-wrap-result-handler (orig-fn &rest args)
    "Override result handler to always show in *cider-result* buffer."
    (let ((result (apply orig-fn args)))
      (my/cider-show-result-in-cider-result-buffer result)))

  ;; (advice-remove 'cider--display-interactive-eval-result #'my/cider-wrap-result-handler)


  (add-hook! cider-repl-mode #'paredit-mode)

  ;; indentation for custom macros
  (put-clojure-indent 'defresource '(1 1 :defn)))

(global-subword-mode 1)

(defun bso/open-line-indent ()
  "Opening a newline and moving text before indentation sucks ass.
This fixes that with better behavior."
  (interactive)
  (open-line 1)
  (indent-for-tab-command)
  (save-excursion
    (forward-line 1)
    (indent-for-tab-command)))

;; (map! "C-o" #'bso/open-line-indent)

(defun bso/join-line ()
  (interactive)
  (save-excursion
    (end-of-line)
    (delete-char 1)
    (just-one-space)
    (end-of-line)
    (delete-horizontal-space)))

(map! "M-j" #'bso/join-line)

(after! flycheck
  (map!
   :n "]e" 'flycheck-next-error
   :n "[e" 'flycheck-previous-error

   :map flycheck-mode-map
   :leader :prefix "!"
   :n "n" 'flycheck-next-error
   :n "p" 'flycheck-previous-error
   :n "e" 'flycheck-explain-error-at-point
   :n "v" 'flycheck-verify-setup
   :n "V" 'flycheck-version))

(use-package! js2-mode
  :config
  (map! :map js2-mode-map
        "M-." nil))

(defconst org-uuid-regexp
  "\\`[0-9a-f]\\{8\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{12\\}\\'"
  "Regular expression matching a universal unique identifier (UUID).")

(use-package! dired
  :config (map!
           :map dired-mode-map
           "T" #'dired-touch-new-file
           "TAB" #'dirvish-subtree-toggle
           "I" #'dired-insert-subdir)

  (defun bso/dired-copy-uuid-from-path (arg)
    (interactive "P")
    (save-excursion
      (beginning-of-buffer)
      (let ((line
             (buffer-substring-no-properties (line-beginning-position)
                                             ;; directory line ends in a `:'
                                             (- (line-end-position) 1))))
        (kill-new
         (--find
          (string-match org-uuid-regexp it)
          (string-split line "/"))))))

  (defun dired-touch-new-file (filename)
    (interactive "sCreate file: ")
    (shell-command
     (format "touch %s"
             (concat (dired-current-directory) filename)))
    (revert-buffer))

  (remove-hook 'dired-mode-hook 'dired-omit-mode))



(remove-hook! 'prog-mode-hook 'highlight-indent-guides-mode)

(defun bso/insert-uuid ()
  (interactive)
  (insert (org-id-uuid)))

;; This should make company mode not care about case sensitivity. It did when I
;; toggled it.
(setq completion-ignore-case t)

(defun bso/open-vterm-popup ()
  "I made this to replace `+popup/toggle', which often returned the messages buffer instead of the kkk"
  (interactive)
  (let ((+popup--inhibit-transient t))
    (cond ((+popup-windows) (+popup/close-all t))
          ((+popup-buffer (get-buffer "*vterm*"))))))

(map!
 :leader
 "~" #'bso/open-vterm-popup)

(use-package! multiple-cursors
  :config
  (defhydra hydra-multiple-cursors (:color blue :hint nil)
    "
 Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Next     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search
 [Click] Cursor at point       [_q_] Quit"
    ("l" mc/edit-lines :exit t)
    ("a" mc/mark-all-like-this :exit t)
    ("n" mc/mark-next-like-this :exit nil)
    ("N" mc/skip-to-next-like-this :exit nil)
    ("M-n" mc/unmark-next-like-this :exit nil)
    ("p" mc/mark-previous-like-this :exit nil)
    ("P" mc/skip-to-previous-like-this :exit nil)
    ("M-p" mc/unmark-previous-like-this :exit nil)
    ("s" mc/mark-all-in-region-regexp :exit t)
    ("0" mc/insert-numbers :exit t)
    ("A" mc/insert-letters :exit t)
    ("<mouse-1>" mc/add-cursor-on-click)
    ;; Help with click recognition in this hydra
    ("<down-mouse-1>" ignore)
    ("<drag-mouse-1>" ignore)
    ("q" nil))

  (setq mc/cmds-to-run-once mc--default-cmds-to-run-once)
  (add-to-list 'mc/cmds-to-run-once 'hydra-multiple-cursors/mc/mark-next-like-this)

  (setq mc/cmds-to-run-for-all mc--default-cmds-to-run-for-all)

  (map!
   :map prog-mode-map
   "M-n" #'hydra-multiple-cursors/body))

(defun bso/add-missing-brackets ()
  (interactive)
  "Inserts matching chars for ({[ until the expression is balanced."
  (let* ((get-matching-char (lambda (char)
                              (let ((matching-pairs '((?\( . ?\))
                                                      (?\{ . ?\})
                                                      (?\[ . ?\])
                                                      (?\) . ?\()
                                                      (?\} . ?\{)
                                                      (?\] . ?\[))))
                                (cdr (assoc char matching-pairs)))))

         (get-my-char (lambda ()
                        (save-excursion
                          (paredit-backward)
                          (unless (looking-at (rx line-start))
                            (let ((matching-char (char-after (point))))
                              (funcall get-matching-char matching-char))))))
         ;; char we're inserting
         char)
    (while (setq char (funcall get-my-char))
      (insert char))))

(defun inc (n)
  "Increment"
  (interactive)
  (+ n 1))

(defun dec (n)
  "Decrement"
  (interactive)
  (- n 1))

(use-package! yaml-pro
  :after yaml-mode
  :hook (yaml-mode . yaml-pro-mode)
  :config
  (add-hook! yaml-mode #'turn-on-smartparens-strict-mode)
  (map! :map yaml-pro-mode-map
        [remap imenu] #'yaml-pro-jump
        :n "zc" #'yaml-pro-fold-at-point
        :n "zo" #'yaml-pro-unfold-at-point
        :n "gk" #'yaml-pro-prev-subtree
        :n "gj" #'yaml-pro-next-subtree
        :n "gK" #'yaml-pro-up-level
        :n "M-k" #'yaml-pro-move-subtree-up
        :n "M-j" #'yaml-pro-move-subtree-down))

(use-package! expand-region
  :init
  (map!
   "M-=" #'er/expand-region
   "M-+" #'er/contract-region))

(use-package! persp-mode
  :config
  (unless (get-buffer "*scratch*")
    (generate-new-buffer "*scratch*")))

(use-package! harpoon
  :init
  (map! :map general-override-mode-map
        "C-c j j" #'harpoon-quick-menu-hydra
        "C-c j a" #'harpoon-add-file
        "C-c j 1" #'harpoon-go-to-1
        "C-c j 2" #'harpoon-go-to-2
        "C-c j 3" #'harpoon-go-to-3
        "C-c j 4" #'harpoon-go-to-4
        "C-c j 5" #'harpoon-go-to-5

        (:after evil
         :leader :prefix "j"
         "j" #'harpoon-quick-menu-hydra
         "a" #'harpoon-add-file
         "1" #'harpoon-go-to-1
         "2" #'harpoon-go-to-2
         "3" #'harpoon-go-to-3
         "4" #'harpoon-go-to-4
         "5" #'harpoon-go-to-5)))

(defun bso/yank-buffer-file-name ()
  (interactive)
  "Yank the buffer file name into the clipboard"
  (kill-new (buffer-file-name)))

(defun window-split-toggle ()
  "Toggle between horizontal and vertical split with two windows."
  (interactive)
  (if (> (length (window-list)) 2)
      (error "Can't toggle with more than 2 windows!")
    (let ((func (if (window-full-height-p)
                    #'split-window-vertically
                  #'split-window-horizontally)))
      (delete-other-windows)
      (funcall func)
      (save-selected-window
        (other-window 1)
        (switch-to-buffer (other-buffer))))))
(map!
 "C-x |" #'window-split-toggle

 "C-x ^" #'doom/window-enlargen)

(setq! lsp-clojure-server-command '("clojure-lsp"))

(add-hook! ruby-mode smartparens-strict-mode)

(defun +org/jump-to-project-local-todo ()
  (interactive)
  (better-jumper-set-jump)
  (find-file
   (concat (projectile-project-root)
           "todo.org")))

(map! :map general-override-mode-map
      :leader :prefix "o"
      "o" '+org/jump-to-project-local-todo)


(setq treesit-language-source-alist
      '((bash        . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (c           . ("https://github.com/tree-sitter/tree-sitter-c"))
        (cpp         . ("https://github.com/tree-sitter/tree-sitter-cpp"))
        (clojure     . ("https://github.com/sogaiu/tree-sitter-clojure"))
        (css         . ("https://github.com/tree-sitter/tree-sitter-css"))
        (elisp       . ("https://github.com/Wilfred/tree-sitter-elisp"))
        (html        . ("https://github.com/tree-sitter/tree-sitter-html"))
        (javascript  . ("https://github.com/tree-sitter/tree-sitter-javascript"))
        (json        . ("https://github.com/tree-sitter/tree-sitter-json"))
        (ruby        . ("https://github.com/tree-sitter/tree-sitter-ruby"))
        (rust        . ("https://github.com/tree-sitter/tree-sitter-rust"))
        (toml        . ("https://github.com/tree-sitter/tree-sitter-toml"))
        (tsx         . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))
        (typescript  . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
        (yaml        . ("https://github.com/ikatyang/tree-sitter-yaml"))))

(use-package! re-builder)

;; TODO update this to work when the comment char is backwards from me, but before anything else
(defun bso/comment-dwim ()
  (interactive)
  (save-excursion
    (if (region-active-p)
        (comment-region (mark)
                        (point))
      (if (eq major-mode 'clojure-mode)
          (cond
           ((looking-at (rx (zero-or-more (or whitespace "\n"))
                            (or "(" "[" "{")))
            (insert "#_"))

           ((looking-at (rx (zero-or-more (or whitespace "\n"))
                            "#_"))
            (progn (search-forward "#_")
                   (paredit-backward-delete 2))))
        (comment-line 1)))))

(map! "M-;" #'bso/comment-dwim
      :map paredit-mode-map
      "M-;" #'bso/comment-dwim)

(after! yuck-mode
  (put 'defwidget 'lisp-indent-function 3)
  (put 'button 'lisp-indent-function 'defun))

(defun bso/delete-horizontal-space-dwim ()
  "DWIM version of `delete-horizontal-space`.

- If between words (whitespace on both sides), reduce to 1 space.
- If just leading/trailing space, delete all.
- If no space, do nothing."
  (interactive)
  (let ((start (point))
        (before (char-before))
        (after (char-after)))
    (cond
     ;; If surrounded by space, reduce to 1 space
     ((and (eq (char-syntax before) ?\ )
           (eq (char-syntax after) ?\ ))
      (just-one-space))

     ;; If only space before, delete it
     ((eq (char-syntax before) ?\ )
      (skip-chars-backward " \t")
      (delete-region (point) start))

     ;; If only space after, delete it
     ((eq (char-syntax after) ?\ )
      (skip-chars-forward " \t")
      (delete-region start (point)))

     ;; Otherwise do nothing
     (t (message "No horizontal space to delete")))))

(map! "M-\\" #'bso/delete-horizontal-space-dwim)

(defun bso/insert-key-description ()
  "Read a key sequence interactively, and insert its human-readable form at point.
For example, pressing C-x C-s will insert the string \"C-x C-s\"."
  (interactive)
  (let ((keys (read-key-sequence "Press key sequence: ")))
    (insert "\"" (key-description keys) "\"")))

(use-package! markdown-mode
  :init
  (add-hook! markdown-mode-hook #'auto-fill-mode))
