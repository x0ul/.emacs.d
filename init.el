;;(put 'erase-buffer 'disabled nil)

;; A E S T H E T I C
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)
(column-number-mode)

(use-package wombat-theme  ;; Optional to manage via use-package
  :init (load-theme 'wombat t))

;; (load-theme 'wombat)

;; Custom face settings
(set-face-background 'default "#111")
(set-face-background 'cursor "#c96")
(set-face-background 'isearch "#c60")
(set-face-foreground 'isearch "#eee")
(set-face-background 'lazy-highlight "#960")
(set-face-foreground 'lazy-highlight "#ccc")
(set-face-foreground 'font-lock-comment-face "#fc0")

;; Packages
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")))
;; (unless package-archive-contents
;;   (package-refresh-contents))

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Load use-package for package management
(eval-when-compile
  (require 'use-package))

;; Keep `custom' from dirtying up .emacs / init.el
(setq custom-file "~/.emacs.d/custom.el")

;; Show line numbers
(global-display-line-numbers-mode)

;; Don't wrap lines
(set-default 'truncate-lines t)

;; Better defaults!
(use-package better-defaults
  :ensure t)
;; ... but let's actually show menus
(menu-bar-mode 1)

;; smartparens
(use-package smartparens
  :ensure t
  :config
  (require 'smartparens-config))

(require 'loadhist)
(file-dependents (feature-file 'cl))

;; Flycheck, needed for python and others?
(use-package flycheck
  :ensure t
  :hook (prog-mode . flycheck-mode))
;; (add-hook 'elpy-mode-hook 'flycheck-mode)

;; Let elixir-ts-mode start it, otherwise problems
;; ;; Tree-sitter configuration
;; (use-package tree-sitter
;;  :ensure t
;;  :hook (prog-mode . tree-sitter-mode)
;;  :config
;;  (use-package tree-sitter-langs
;;    :ensure t))

;; Elixir
(defun ensure-elixir-ts-grammar ()
  "Ensure that the Elixir Treesitter grammar is installed."
  (unless (file-exists-p (expand-file-name "libtree-sitter-elixir.so" (concat (expand-file-name user-emacs-directory) "tree-sitter")))
    (message "Elixir Treesitter grammar not found. Installing...")
    (elixir-ts-install-grammar)))

(use-package elixir-ts-mode
  :ensure t
  :hook
  ((elixir-ts-mode . flycheck-mode)
   (elixir-ts-mode . smartparens-mode)
   (elixir-ts-mode . mix-minor-mode)
   (elixir-ts-mode . exunit-mode)
   (elixir-ts-mode . ensure-elixir-ts-grammar))
  :config
  (add-to-list 'auto-mode-alist '("\\.exs?\\'" . elixir-ts-mode))
  (add-hook 'elixir-ts-mode-hook (lambda ()
                                           (add-hook 'before-save-hook 'lsp-format-buffer))))
(use-package
  flycheck-credo
  :ensure t
  :after (flycheck elixir-ts-mode)
  :config
  (flycheck-credo-setup)
  :custom (flycheck-elixir-credo-strict t))

(use-package
  exunit
  :ensure t
  :after elixir-ts-mode
  :bind
    (:map elixir-ts-mode-map
        ("C-c , a" . exunit-verify-all)
        ("C-c , A" . exunit-verify-all-in-umbrella)
        ("C-c , s" . exunit-verify-single)
        ("C-c , v" . exunit-verify)
        ("C-c , r" . exunit-rerun)
        ("C-c , t" . exunit-toggle-file-and-test)
        ("s-r" . exunit-rerun)
        ))

(use-package
  mix
  :ensure t
  :hook (elixir-ts-mode . mix-minor-mode)
  :after elixir-ts-mode)

(use-package lsp-mode
  :ensure t
  :hook (elixir-ts-mode . lsp)
  :diminish lsp-mode
  :commands lsp)

(use-package lsp-ui
  :ensure t
  :after lsp-mode)

(use-package yasnippet
  :ensure t
  :config (yas-global-mode 1))

(use-package company
  :ensure t
  :hook (prog-mode . company-mode))

(use-package dap-mode
  :ensure t
  :config
  ;; Enable dap-ui and dap-mode globally or for specific modes
  (dap-ui-mode 1)
  (dap-mode 1))

;; Python configuration
(use-package elpy
  :ensure t
  :init
  :config
  (setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")
  (setq elpy-test-runner 'elpy-test-pytest-runner)
  (setq elpy-test-pytest-runner-command '("pytest" "-sv"))
  (elpy-enable))
(remove-hook 'elpy-modules 'elpy-module-flymake)

;; Used by pipenv!
(use-package pyvenv
  :ensure t)

;; Kind of feels like pipenv is the preferred way of doing virtual
;; environments and package management. Stuff goes in ~/.local, it
;; ties into Projectile and/or directories containing Pipfiles.
;; Note to self: C-c C-p ...
;; (use-package pipenv
;;   :hook (python-mode . pipenv-mode)
;;   :init
;;   (setq
;;    pipenv-projectile-after-switch-function
;;    #'pipenv-projectile-after-switch-extended))

;; Org mode configuration
(use-package org
  :ensure t
  :hook (org-mode . org-superstar-mode)
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda))
  :config
  (setq org-log-done t)
  (setq org-startup-indented t)
  (setq org-duration-format 'h:mm))

(use-package org-pomodoro
  :ensure t
  :hook (org-mode . org-superstar-mode))

(use-package org-superstar
  :ensure t)

;; TODO look at vertico and consult
;; which-key
(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

;; much better!
(add-hook 'before-save-hook 'whitespace-cleanup)
;; These don't work very well with high-res
;;(setq-default indicate-empty-lines t)
;;(setq-default indicate-buffer-boundaries 'left)
(setq sentence-end-double-space nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4) ;; eg. for Makefiles
(setq show-paren-delay 0)
(show-paren-mode)

(use-package cc-mode
  :config
  (setq c-basic-offset 4))

;; Auto-save files somewhere else
(make-directory "~/.emacs.d/backup/" t)
(setq auto-save-file-name-transforms'((".*" "~/.emacs.d/backup/" t)))
(setq backup-directory-alist '(("." . "~/.emacs.d/backup/")))
(setq create-lockfiles nil)

;; Auto-add newlines
(define-key global-map (kbd "RET") 'newline-and-indent)
(setq next-line-add-newlines t)

;; Use-package based configuration for packages you like
(use-package markdown-mode
  :ensure t)

(use-package paredit
  :ensure t)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode) ;; Enable rainbow-delimiters in programming modes
  :config
  ;; Custom colors for rainbow-delimiters
  (set-face-foreground 'rainbow-delimiters-depth-1-face "#c66")  ; red
  (set-face-foreground 'rainbow-delimiters-depth-2-face "#6c6")  ; green
  (set-face-foreground 'rainbow-delimiters-depth-3-face "#69f")  ; blue
  (set-face-foreground 'rainbow-delimiters-depth-4-face "#cc6")  ; yellow
  (set-face-foreground 'rainbow-delimiters-depth-5-face "#6cc")  ; cyan
  (set-face-foreground 'rainbow-delimiters-depth-6-face "#c6c")  ; magenta
  (set-face-foreground 'rainbow-delimiters-depth-7-face "#ccc")  ; light gray
  (set-face-foreground 'rainbow-delimiters-depth-8-face "#999")  ; medium gray
  (set-face-foreground 'rainbow-delimiters-depth-9-face "#666")) ; dark gray

(use-package rust-mode
  :ensure t)

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status))) ;; Bind magit-status to C-x g

;; Winner Mode for quickly switching back after new windows pop open
(winner-mode 1)

;; Window navigation with switch-window
(use-package switch-window
  :ensure t
  :bind (("C-x o" . switch-window)
         ("C-x 1" . switch-window-then-maximize)
         ("C-x 2" . switch-window-then-split-below)
         ("C-x 3" . switch-window-then-split-right)
         ("C-x 0" . switch-window-then-delete)
         ("C-x 4 d" . switch-window-then-dired)
         ("C-x 4 f" . switch-window-then-find-file)
         ("C-x 4 m" . switch-window-then-compose-mail)
         ("C-x 4 r" . switch-window-then-find-file-read-only)
         ("C-x 4 C-f" . switch-window-then-find-file)
         ("C-x 4 C-o" . switch-window-then-display-buffer)
         ("C-x 4 0" . switch-window-then-kill-buffer)))


;; Ensure the Emacs server is running
(use-package server
  :ensure nil  ;; `server` is built-in, no need to ensure
  :config
  (unless (server-running-p)
    (server-start)))

;; Projectile
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

;; Treemacs
(use-package treemacs
  :ensure t
  :defer t
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

;; Ivy/Counsel/Swiper
(use-package ivy
  :ensure t
  :diminish
  :bind (("C-c C-r" . ivy-resume)
         ("C-x B" . ivy-switch-buffer-other-window))
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (ivy-mode 1))

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-r" . counsel-recentf)
         ("C-c g" . counsel-git)
         ("C-c j" . counsel-git-grep)
         ("C-c k" . counsel-ag)
         ("C-c l" . counsel-locate)))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))
(use-package swiper
  :ensure t
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

;; Misc crap
(define-coding-system-alias 'UTF-8 'utf-8)
(put 'upcase-region 'disabled nil)
