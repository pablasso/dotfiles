;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (diff-hl diff-hl-mode bm evil-leader dashboard ag counsel-projectile zoom-window treemacs-icons-dired treemacs-magit treemacs-projectile treemacs-evil treeview sidebar elpy dash-at-point hlinum company robe evil-magit magit ivy-rich counsel ivy helm projectile doom-theme doom-themes evil tc use-package)))
 '(zoom-window-mode-line-color "DarkGreen"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; visual
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-linum-mode t)
(show-paren-mode)
(set-default-font "Hack 14")

;; generic
(setq backup-directory-alist `(("." . "~/.saves")))
(setq mac-option-modifier 'meta)
(setq mac-command-modifier 'super)

;; packages

; run after install: M-x all-the-icons-install-fonts
(use-package all-the-icons
  :ensure t)

(use-package doom-themes
  :ensure t
  :config
  (doom-themes-treemacs-config)
  (load-theme 'doom-one t))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(use-package hlinum
  :ensure t
  :config
  (hlinum-activate))


(use-package evil-leader
  :ensure t
  :config
  (evil-leader/set-leader ",")
  (evil-leader/set-key
    "1" 'projectile-previous-project-buffer
    "2" 'projectile-next-project-buffer
    "3" 'bm-previous
    "4" 'bm-next
    "a" 'counsel-projectile-ag
    "b" 'counsel-projectile-switch-to-buffer
    "d" 'dash-at-point
    "f" 'counsel-projectile-find-file
    "g" 'magit
    "j" 'lsp-find-definition
    "m" 'bm-toggle
    "p" 'counsel-projectile-switch-project
    "s" 'swiper
    "t" 'treemacs
    "w" 'kill-current-buffer
    "z" 'zoom-window-zoom)
  (global-evil-leader-mode))

(use-package evil
  :ensure t
  :after evil-leader
  :config
  (evil-mode 1))

(use-package ivy
  :ensure t
  :config
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (defalias #'forward-evil-word #'forward-evil-symbol) ; select full words like vim does with w
  (ivy-mode 1))

(use-package counsel
  :ensure t
  :after ivy
  :config
  (counsel-mode 1))

(use-package ivy-rich
  :ensure t
  :after ivy
  :config
  (ivy-rich-mode 1))

(use-package swiper
  :ensure t
  :after ivy)

(use-package projectile
  :ensure t
  :config
  (setq projectile-completion-system 'ivy)
  (setq projectile-project-search-path '("~/dev/"))
  (projectile-mode +1))

(use-package counsel-projectile
  :ensure t
  :after counsel projectile
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (counsel-projectile-mode 1))

(use-package ag
  :ensure t)

(use-package treemacs
  :ensure t
  :config
  ; TODO: remove this ugly fixed path, how can we load pyenv instead?
  (setq treemacs-python-executable (executable-find "/Users/pablasso/.pyenv/versions/3.7.2/bin/python"))
  (add-to-list 'treemacs-pre-file-insert-predicates #'treemacs-is-file-git-ignored?)
  (treemacs-git-mode 'extended))

(use-package treemacs-evil
  :after treemacs evil
  :ensure t)

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package magit
  :ensure t)

(use-package evil-magit
  :ensure t)

(use-package company
  :ensure t 
  :config
  (add-hook 'after-init-hook 'global-company-mode))

(use-package dash-at-point
  :ensure t)

(use-package lsp-mode
  :ensure t
  :commands lsp
  :config
  (require 'lsp-clients)
  (setq lsp-prefer-flymake :none)
  (add-hook 'python-mode-hook 'lsp)
  (add-hook 'ruby-mode-hook 'lsp)
  (lsp-register-client
   ; TODO: this server is a bash script using pyls, figure out how to load pyenv beforehand instead
   (make-lsp-client :new-connection (lsp-stdio-connection "pyserver")
                    :major-modes '(python-mode)
                    :server-id 'pyls))
  (lsp-register-client
   ; TODO: this server is a bash script using solargraph, figure out how to load rbenv beforehand instead
   (make-lsp-client :new-connection (lsp-stdio-connection "rubyserver")
                    :major-modes '(ruby-mode)
                    :server-id 'ruby-ls)))

(use-package company-lsp
  :ensure t
  :config
  (push 'company-lsp company-backends))

(use-package zoom-window
  :ensure t
  :config
  (custom-set-variables
   '(zoom-window-mode-line-color "DarkGreen")))

(use-package bm
  :ensure t
  :config
  (setq bm-cycle-all-buffers t))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode))
