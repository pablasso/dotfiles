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
    (dashboard ag counsel-projectile zoom-window treemacs-icons-dired treemacs-magit treemacs-projectile treemacs-evil treeview sidebar elpy dash-at-point hlinum company robe evil-magit magit ivy-rich counsel ivy helm projectile doom-theme doom-themes evil tc use-package)))
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
(set-default-font "Hack 13")

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

(use-package evil
  :ensure t
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
  :after ivy
  :bind
  (("C-s" . swiper)))

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
  :bind
  (:map global-map
	("C-x t t" . treemacs))
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
  :ensure t
  :config
  (global-set-key (kbd "C-c g") 'magit-status))

(use-package evil-magit
  :ensure t)

(use-package company
  :ensure t 
  :config
  (add-hook 'after-init-hook 'global-company-mode))

(use-package dash-at-point
  :ensure t
  :config
  :bind (("C-c d" . dash-at-point)))

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
  (global-set-key (kbd "C-x C-z") 'zoom-window-zoom)
  (custom-set-variables
   '(zoom-window-mode-line-color "DarkGreen")))
