;;(put 'erase-buffer 'disabled nil)

;; A E S T H E T I C
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)
(column-number-mode)
(load-theme 'wombat)
;; TODO look into color-theme to share this?
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
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("org" . "https://orgmode.org/elpa/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Keep `custom' from dirtying up .emacs / init.el
(setq custom-file "~/.emacs.d/custom.el")

;; Show line numbers
(global-display-line-numbers-mode)

;; Don't wrap lines
(set-default 'truncate-lines t)

;; Better defaults!
(use-package better-defaults)
;; ... but let's actually show menus
(menu-bar-mode 1)

;; Flycheck, needed for python and others?
(use-package flycheck)
(add-hook 'elpy-mode-hook 'flycheck-mode)

;; Python configuration
(use-package elpy
  :ensure t
  :init
  :config
  (setq python-shell-interpreter "ipython3"
      python-shell-interpreter-args "-i --simple-prompt")
  (elpy-enable))

;; Used by pipenv!
(use-package pyvenv
  :ensure t
  :init
  (setenv "WORKON_HOME" "~/.pyenv/versions"))

;; Kind of feels like pipenv is the preferred way of doing virtual
;; environments and package management. Stuff goes in ~/.local, it
;; ties into Projectile and/or directories containing Pipfiles.
;; Note to self: C-c C-p ...
(use-package pipenv
  :hook (python-mode . pipenv-mode)
  :init
  (setq
   pipenv-projectile-after-switch-function
   #'pipenv-projectile-after-switch-extended))

;; Terminal use vterm
(use-package vterm
  :ensure t )

;; Org mode configuration
(use-package org)
(add-hook 'org-mode-hook (lambda() (org-superstar-mode 1)))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(require 'org-journal)

;; Make life easier finding files
;;(ido-mode 1)
;;(ido-everywhere)

;; TODO look at vertico and consult
;; TODO which-key
(use-package which-key
  :config
  (which-key-mode 1))

(setq ido-enable-flex-matching t)
;; Ask to open as root
(add-to-list 'load-path "~/.emacs.d/lisp")
(defadvice ido-find-file (after find-file-sudo activate)
  "Find file as root if necessary."
  (unless (and buffer-file-name
               (file-writable-p buffer-file-name))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

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

;; Packages I like
(setq package-list '(markdown-mode paredit rainbow-delimiters rust-mode org-journal company magit pipenv))
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; Paredit
;; (add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
;; (add-hook 'eval-expression-minibuffer-setup-hook 'enable-paredit-mode)
;; (add-hook 'ielm-mode-hook 'enable-paredit-mode)
;; (add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
;; (add-hook 'lisp-mode-hook 'enable-paredit-mode)

;; Rainbows
(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-interaction-mode-hook 'rainbow-delimiters-mode)
(add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)
(require 'rainbow-delimiters)
(set-face-foreground 'rainbow-delimiters-depth-1-face "#c66")  ; red
(set-face-foreground 'rainbow-delimiters-depth-2-face "#6c6")  ; green
(set-face-foreground 'rainbow-delimiters-depth-3-face "#69f")  ; blue
(set-face-foreground 'rainbow-delimiters-depth-4-face "#cc6")  ; yellow
(set-face-foreground 'rainbow-delimiters-depth-5-face "#6cc")  ; cyan
(set-face-foreground 'rainbow-delimiters-depth-6-face "#c6c")  ; magenta
(set-face-foreground 'rainbow-delimiters-depth-7-face "#ccc")  ; light gray
(set-face-foreground 'rainbow-delimiters-depth-8-face "#999")  ; medium gray
(set-face-foreground 'rainbow-delimiters-depth-9-face "#666")  ; dark gray

;; Custom commands
(defun show-current-time ()
  "Show current time for two seconds."
  (interactive)
  (message (current-time-string))
  (sleep-for 2)
  (message nil))
(global-set-key (kbd "C-c t") 'show-current-time)

;; Language servers
;;(add-to-list 'elglot-server-programs '(html-mode . ("

;; Server-client stuff
(require 'server)
(unless (server-running-p)
  (server-start))

;; Projectile
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

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
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")
(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)

(global-set-key (kbd "C-c c") 'counsel-compile)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c L") 'counsel-git-log)
(global-set-key (kbd "C-c k") 'counsel-rg)
(global-set-key (kbd "C-c m") 'counsel-linux-app)
(global-set-key (kbd "C-c n") 'counsel-fzf)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-c J") 'counsel-file-jump)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(global-set-key (kbd "C-c w") 'counsel-wmctrl)

(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "C-c b") 'counsel-bookmark)
(global-set-key (kbd "C-c d") 'counsel-descbinds)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c o") 'counsel-outline)
(global-set-key (kbd "C-c t") 'counsel-load-theme)
(global-set-key (kbd "C-c F") 'counsel-org-file)
