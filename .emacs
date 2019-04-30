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
 '(custom-safe-themes
   (quote
    ("6b2636879127bf6124ce541b1b2824800afc49c6ccd65439d6eb987dbf200c36" "392395ee6e6844aec5a76ca4f5c820b97119ddc5290f4e0f58b38c9748181e8d" "30289fa8d502f71a392f40a0941a83842152a68c54ad69e0638ef52f04777a4c" "bf798e9e8ff00d4bf2512597f36e5a135ce48e477ce88a0764cfb5d8104e8163" "c9ddf33b383e74dac7690255dd2c3dfa1961a8e8a1d20e401c6572febef61045" "36ca8f60565af20ef4f30783aa16a26d96c02df7b4e54e9900a5138fb33808da" "6b289bab28a7e511f9c54496be647dc60f5bd8f9917c9495978762b99d8c96a0" "4697a2d4afca3f5ed4fdf5f715e36a6cac5c6154e105f3596b44a4874ae52c45" "d2e9c7e31e574bf38f4b0fb927aaff20c1e5f92f72001102758005e53d77b8c9" "49ec957b508c7d64708b40b0273697a84d3fee4f15dd9fc4a9588016adee3dad" "cd736a63aa586be066d5a1f0e51179239fe70e16a9f18991f6f5d99732cabb32" "6d589ac0e52375d311afaa745205abb6ccb3b21f6ba037104d71111e7e76a3fc" "fe666e5ac37c2dfcf80074e88b9252c71a22b6f5d2f566df9a7aa4f9bea55ef8" "10461a3c8ca61c52dfbbdedd974319b7f7fd720b091996481c8fb1dded6c6116" default)))
 '(package-selected-packages
   (quote
    (lsp-ui company-lsp lsp-mode doom-modeline ample-theme plan9-theme flatui-theme exec-path-from-shell web-mode editorconfig olivetti diff-hl diff-hl-mode bm evil-leader dashboard ag counsel-projectile zoom-window treemacs-icons-dired treemacs-magit treemacs-projectile treemacs-evil treeview sidebar elpy dash-at-point hlinum company robe evil-magit magit ivy-rich counsel ivy helm projectile doom-theme doom-themes evil tc use-package)))
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
(show-paren-mode)
(set-default-font "Hack 14")
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; remap key-bindings
(setq mac-option-modifier 'meta)
(setq mac-command-modifier 'super)

;; packages

; load the same PATH as our user in Mac OS or Linux
; necessary since we're starting from a GUI not the terminal
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize)))

(use-package no-littering
  :ensure t
  :config
  (setq auto-save-file-name-transforms
    `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

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
    "[" 'diff-hl-previous-hunk
    "]" 'diff-hl-next-hunk
    "1" 'projectile-previous-project-buffer
    "2" 'projectile-next-project-buffer
    "3" 'bm-previous
    "4" 'bm-next
    "a" 'counsel-projectile-ag
    "b" 'counsel-projectile-switch-to-buffer
    "d" 'dash-at-point
    "f" 'counsel-projectile-find-file
    "g" 'magit
    "j" 'lsp-ui-peek-find-definitions
    "m" 'bm-toggle
    "p" 'counsel-projectile-switch-project
    "r" 'lsp-ui-peek-find-references
    "s" 'swiper
    "t" 'treemacs
    "u" 'diff-hl-revert-hunk
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
  (setq projectile-project-search-path '("~/dev/personal"))
  (setq projectile-project-search-path '("~/dev/topfunnel"))
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

(use-package lsp-ui
  :ensure t)

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
  (diff-hl-margin-mode)
  (global-diff-hl-mode))

(use-package olivetti
  :ensure t)

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.es6$" . web-mode))
  (setq web-mode-content-types-alist '(("jsx" . "\\.es6\\'")))
  (setq web-mode-enable-current-column-highlight t))
