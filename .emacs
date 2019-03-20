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
    (dash-at-point hlinum company robe evil-magit magit neotree ivy-rich counsel ivy helm projectile doom-theme doom-themes evil tc use-package))))
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

;; generic
(setq backup-directory-alist `(("." . "~/.saves")))
(setq mac-option-modifier 'meta)
(setq mac-command-modifier 'super)

;; packages
(use-package all-the-icons
  :ensure t)

(use-package doom-themes
  :ensure t
  :config
  (doom-themes-neotree-config)
  (load-theme 'doom-one t))

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
  (global-set-key (kbd "C-c s") 'counsel-ag)
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
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (projectile-mode +1))

(use-package neotree
  :ensure t
  :config
  (setq-default neo-show-hidden-files t) ; show hidden files by default
  (setq neo-window-fixed-size nil) ; resizable window
  ; the following opens with focus on the file opened in the buffer
  (defun neotree-project-dir-toggle ()
  "Open NeoTree using the project root, using find-file-in-project,
  or the current buffer directory."
  (interactive)
  (let ((project-dir
	 (ignore-errors
	 ;;; Pick one: projectile or find-file-in-project
	 ; (projectile-project-root)
	 (ffip-project-root)
	 ))
       (file-name (buffer-file-name))
       (neo-smart-open t))
    (if (and (fboundp 'neo-global--window-exists-p)
	     (neo-global--window-exists-p))
	(neotree-hide)
      (progn
	(neotree-show)
	(if project-dir
	    (neotree-dir project-dir))
	(if file-name
	    (neotree-find file-name))))))
  (global-set-key (kbd "C-c m") 'neotree-project-dir-toggle))

(use-package magit
  :ensure t
  :config
  (global-set-key (kbd "C-c g") 'magit-status))

(use-package evil-magit
  :ensure t)

(use-package robe
  :ensure t
  :bind ("C-c ." . robe-jump)
  :config
  (add-hook 'ruby-mode-hook 'robe-mode))

(use-package company
  :ensure t 
  :config
  (push 'company-robe company-backends)
  (add-hook 'after-init-hook 'global-company-mode))

(use-package dash-at-point
  :ensure t
  :config
  :bind (("C-c d" . dash-at-point)))
