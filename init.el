;;; -*- lexical-binding: t -*-

;;; ============================ PREREQUISITES =================================

;; Reduce the frequency of garbage collection by making it happen on
;; each 25MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 25000000)

;;; ============================== CONSTANTS ===================================

(defconst USERNAME
  (getenv (if (equal system-type 'window-nt) "USERNAME" "USER"))
  "The name of the user.")

;;; =============================== PACKAGES ===================================

(require 'package)
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq package-check-signature 'allow-unsigned)

(defconst PACKAGES
  '(gnu-elpa-keyring-update
    ace-window
    which-key
    hl-todo

    org-journal

    zenburn-theme
    spacemacs-theme

    paredit
    rainbow-delimiters
    geiser
    geiser-guile
    racket-mode

    elpy
    blacken

    flycheck

    auctex
    cdlatex

    ediprolog

    yasnippet)
  "List of required packages")

(dolist (package PACKAGES)
  (unless (package-installed-p package)
    (package-install package)))

(add-to-list 'load-path (expand-file-name "vendor" user-emacs-directory))

;;; =========================== CUSTOM FUNCTIONS ===============================

(defun open-init ()
  "Open the init file."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(defun germanify-bonanza (char)
  "Insert a common german character based on CHAR."
  (interactive "cLetter: ")
  (cond ((eq char ?a) (insert "ä"))
        ((eq char ?o) (insert "ö"))
        ((eq char ?u) (insert "ü"))
        ((eq char ?A) (insert "Ä"))
        ((eq char ?O) (insert "Ö"))
        ((eq char ?U) (insert "Ü"))
        ((eq char ?s) (insert "ß"))
        ((eq char ?S) (insert "ẞ"))
        (t (error "No german character associated with input!"))))

(defun make-section-comment (name start &optional end)
  "Create a comment indicating a new source code section with
NAME. START and END are the comment delimiters. END can be
ommited. The length of the comment and maximum length of the name
rely on the variable `fill-column', so it needs to be set to an
appropriate value in order for this function to work."
  (when (or (not fill-column) (= fill-column 0))
    (error "Set 'fill-column' to a non-nil and non-zero numeric value!"))

  (let ((MAX_LEN (- fill-column
                    (+ 6
                       (* 2 (length start))))))
    (when (> (length name) MAX_LEN)
      (error "Section name cannot be longer than %d characters!" MAX_LEN)))

  (let* ((S (center-string-in-char (concat " " name " ") fill-column ?=)))
    (move-beginning-of-line 1)
    (store-substring S 0 start)
    (when end
      (store-substring S (- (length S) (length end)) end))
    (insert S)
    (newline)))

(defun center-string-in-char (str len char)
  "Center STR within LEN characters, with CHAR as filler."
  (store-substring (make-string len char) (/ (- len (length str)) 2) str))

;;; =========================== GLOBAL SETTINGS ================================

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode +1)

(global-hl-line-mode +1)
(global-display-line-numbers-mode +1)

(setq-default fill-column 80)
(setq-default indent-tabs-mode nil)
;; (setq-default show-trailing-whitespace +1)

(setq make-backup-files nil)
(setq custom-file (concat user-emacs-directory "/custom.el"))
(setq inhibit-startup-screen +1)
(setq display-line-numbers-type 'relative)
(setq show-trailing-whitespace +1)
(setq shift-select-mode nil)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

(require 'ace-window)
(global-set-key (kbd "C-x o") 'ace-window)

(require 'which-key)
(which-key-mode +1)

(require 'which-func)
(which-function-mode +1)
(setq which-func-unknown "n/a")

(require 'hl-todo)
(global-hl-todo-mode +1)

(global-set-key (kbd "C-x /") 'germanify-bonanza)

;;; =============================== VISUALS ====================================

(require 'zenburn-theme)
(setq custom-safe-themes t)
(load-theme 'zenburn)
(set-face-attribute 'default nil
                    :font "Fira Code 11"
                    :height 110)
(set-face-attribute 'cursor nil
                    :background "#FF006D")

;;; =========================== WHITESPACE MODE ================================

(setq-default whitespace-style
              '(face
                spaces
                empty
                tabs
                newline
                trailing
                space-mark
                tab-mark
                newline-mark))

;; Whitespace color corrections

(custom-set-faces
 `(whitespace-space
   ((t (:foreground "#4F4F4F" :background nil))))
 `(whitespace-tab
   ((t (:foreground "#4F4F4F" :background nil))))
 `(whitespace-newline
   ((t (:foreground "#4F4F4F" :background nil))))

 `(whitespace-missing-newline-at-eof
   ((t (:foreground "#2791d8" :background "#AB54A9"))))
 `(whitespace-space-after-tab
   ((t (:foreground "#2791d8" :background "#AB54A9"))))
 `(whitespace-space-before-tab
   ((t (:foreground "#2791d8" :background "#AB54A9"))))
 `(whitespace-trailing
   ((t (:foreground "#2791d8" :background "#AB54A9")))))

(setq whitespace-display-mapping
      '((space-mark 32 [183] [46])
        (newline-mark ?\n [172 ?\n] [36 ?\n])
        (newline-mark ?\r [182] [35])
        (tab-mark ?\t [187 ?\t] [62 ?\t])))

(setq-default whitespace-action
              '(cleanup auto-cleanup))

;; Don't enable whitespace for.
(setq-default whitespace-global-modes
              '(not shell-mode
                    help-mode
                    magit-mode
                    magit-diff-mode
                    ibuffer-mode
                    dired-mode
                    occur-mode

                    racket-repl-mode
                    geiser-repl-mode))

(global-whitespace-mode +1)
(global-display-fill-column-indicator-mode +1)
(auto-fill-mode +1)

;;; ============================== YASNIPPET ===================================

(require 'yasnippet)

(setq yas-snippet-dirs
      (list (expand-file-name "snippets" user-emacs-directory)))

(yas-global-mode 1)

;;; ================================= LISP =====================================

(require 'geiser)
(require 'geiser-guile)
(require 'racket-mode)
;; (require 'scribble)

(add-to-list 'auto-mode-alist '("\\.scm\\'" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.ss\\'" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode))
(add-to-list 'auto-mode-alist '("\\.scrbl\\'" . racket-hash-lang-mode))

(defun make-lisp-section-comment (name)
  "Create a comment indicating a new source code section with
NAME for LISP source files. Calls the function
`make-section-comment' for the \"heavy\" work. That function
relies on `fill-column'."
  (interactive "sName of section: ")
  (make-section-comment name ";;; "))

(defun my-lisp-mode-hook ()
  "Hook for my LISP mode configurations"
  (local-set-key (kbd "C-c / r") 'make-lisp-section-comment)
  (paredit-mode +1)
  (rainbow-delimiters-mode +1))

(defun my-lisp-repl-mode-hook ()
  "Hook for my LISP REPL mode configurations"
  (electric-pair-mode +1)
  (rainbow-delimiters-mode +1))

(defun insert-lexical-binding-string-for-elisp ()
  (save-excursion
    (goto-char 0)
    (let ((str ";;; -*- lexical-binding: t -*-")
          (first-line (buffer-substring (point)
                                        (progn
                                          (move-end-of-line nil)
                                          (point)))))
      (unless (string= str first-line)
        (goto-char 0)
        (insert (concat str "\n\n"))))))

(add-hook 'scheme-mode-hook 'my-lisp-mode-hook)
(add-hook 'racket-mode-hook 'my-lisp-mode-hook)
(add-hook 'emacs-lisp-mode-hook 'my-lisp-mode-hook)
(add-hook 'lisp-interaction-mode-hook 'my-lisp-mode-hook)
(add-hook 'lisp-mode-hook 'my-lisp-mode-hook)

(add-hook 'geiser-repl-mode-hook 'my-lisp-repl-mode-hook)
(add-hook 'racket-repl-mode-hook 'my-lisp-repl-mode-hook)

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq lexical-binding t)
            (insert-lexical-binding-string-for-elisp)))

;;; ================================== C =======================================

(defun make-c-section-comment (name)
  "Create a comment indicating a new source code section with
NAME for C source files. Calls the function
`make-section-comment' for the \"heavy\" work. That function
relies on `fill-column'."
  (interactive "sName of section: ")
  (make-section-comment name "/* " " */"))

(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))
            ;; additional config
            (local-set-key (kbd "C-c / r") 'make-c-section-comment)
            (local-set-key (kbd "C-c / c") 'compile)))

(add-hook 'c-mode-hook
          (lambda ()
            (setq indent-tabs-mode t)
            (c-set-style "linux-tabs-only")
            (electric-pair-mode +1)
            (rainbow-delimiters-mode +1)))

;;; ================================ PYTHON ====================================

(defun make-python-section-comment (name)
  "Create a comment indicating a new source code section with
NAME for Python source files. Calls the function
`make-section-comment' for the \"heavy\" work. That function
relies on `fill-column'."
  (interactive "sName of section: ")
  (make-section-comment name "# "))

(elpy-enable)
(setq elpy-rpc-virtualenv-path 'current)
(setenv "WORKON_HOME" (concat (getenv "HOME") "/miniconda3/envs"))
(setq blacken-line-length 'fill)

(add-hook 'elpy-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c / r") 'make-python-section-comment)
            (blacken-mode)
            (electric-pair-mode +1)
            (rainbow-delimiters-mode +1)))

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;;; ================================ PROLOG ====================================

(defun make-prolog-section-comment (name)
  "Create a comment indicating a new source code section with
NAME for Prolog source files. Calls the function
`make-section-comment' for the \"heavy\" work. That function
relies on `fill-column'."
  (interactive "sName of section: ")
  (make-section-comment name "/* " " */"))

(setq auto-mode-alist (append '(("\\.pl$" . prolog-mode))
                               auto-mode-alist))

(add-hook 'prolog-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c q") 'make-prolog-section-comment)
            (electric-pair-mode +1)
            (rainbow-delimiters-mode +1)))

;;; ================================ LATEX =====================================

(require 'latex)
(require 'auctex)
(require 'cdlatex)

(setq TeX-engine 'luatex)
(setq TeX-PDF-mode t)
(setq TeX-auto-save nil)
(setq TeX-parse-self nil)

(setq LaTeX-item-indent 0)

(defun make-latex-section-comment (name)
  "Create a comment indicating a new source code section with
NAME for LaTeX source files. Calls the function
`make-section-comment' for the \"heavy\" work. That function
relies on `fill-column'."
  (interactive "sName of section: ")
  (make-section-comment name "% "))

(defun my-latex-mode-hook ()
  "Hook for my LaTeX mode configurations"
  (local-set-key (kbd "C-c / r") 'make-latex-section-comment)
  (setq TeX-command-default "LaTeX")
  (setq TeX-engine 'luatex)
  ;; TODO: handle this better?
  (LaTeX-indent-commands-regexp-make))

(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
(add-hook 'LaTeX-mode-hook 'pretty-symbols-mode)
(add-hook 'LaTeX-mode-hook 'turn-on-cdlatex)
(add-hook 'LaTeX-mode-hook 'my-latex-mode-hook)

;;; ================================= ORG ======================================

(require 'org-journal)

(setq org-journal-file-type 'daily)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (scheme . t)))

;;; ================================= END ======================================

(message "Enjoy Emacs, %s" USERNAME)

(provide 'init)
;;; init.el ends here
