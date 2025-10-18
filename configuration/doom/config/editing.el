;;; ../../code/dotfiles/configuration/doom/config/editing.el -*- lexical-binding: t; -*-

(use-package! better-jumper
  :config
  (defun bso-advice/set-jump! (&rest args)
    "Sets a jump point ignoring all args."
    (better-jumper-set-jump))

  ;; These aren't setting the jump by default.
  ;; Custom fn
  (advice-add '+lookup/definition :before #'bso-advice/set-jump!)
  (advice-add '+lookup/type-definition :before #'bso-advice/set-jump!))

(use-package! avy
  :init
  (setq! avy-all-windows t)
  (define-key!
    "C-." #'avy-goto-char-timer))

(use-package! ace-window
  :defer nil
  :config
  (setq!  aw-scope 'frame
          aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))

  (map! "M-o"     #'ace-window
        "C-x o"  #'ace-window))

(use-package! smartparens
  :init
  (map!
   :map smartparens-mode-map
   "M-s" 'sp-splice-sexp
   "C-M-u" #'sp-backward-up-sexp
   "C-<right>" #'sp-slurp-hybrid-sexp
   "C-<left>" #'sp-forward-barf-sexp))

(use-package! dired
  :config (map!
           :map dired-mode-map
           "T" #'dired-touch-new-file
           "TAB" #'dirvish-subtree-toggle
           "I" #'dired-insert-subdir)

  (defun bso/dired-copy-uuid-from-path (arg)
    (interactive "P")
    (save-excursion
      (goto-char (point-min))
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

(use-package! expand-region
  :init
  (map!
   "M-=" #'er/expand-region
   "M-+" #'er/contract-region))

(use-package! persp-mode
  :init

  (defun bso/persp-kill-this-buffer ()
    "Kill the current buffer (only in this perspective)"
    (interactive)
    (persp-kill-buffer (current-buffer)))

  (map! "C-x k" #'bso/persp-kill-this-buffer)

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
        "C-c j 5" #'harpoon-go-to-5))



(map!
 "C-x |" #'window-split-toggle

 "C-x ^" #'doom/window-enlargen)

(after! projectile
  (map!
   :map projectile-mode-map
   "M-O" #'projectile-find-file
   "M-F" #'+default/search-project

   :leader :prefix "p"
   :n "t" #'projectile-toggle-between-implementation-and-test))

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

(use-package! markdown-mode
  :init
  (add-hook! markdown-mode-hook #'auto-fill-mode))
