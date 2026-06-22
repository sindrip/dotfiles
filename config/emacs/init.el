;;; -*- lexical-binding: t; -*-

;; No foo~ backup files or .#foo lockfiles
(setq make-backup-files nil)
(setq create-lockfiles nil)

;; Redirect Customize output to a separate file to keep init.el clean
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Show column number in mode line
(column-number-mode 1)
;; y/n instead of yes/no prompts
(setq use-short-answers t)
(blink-cursor-mode -1)
;; No audible or visible bell
(setq ring-bell-function #'ignore)
;; Disable matching paren highlight
(show-paren-mode -1)
;; Compact mode line when it gets long
(setq mode-line-compact 'long)
;; Smooth trackpad scrolling
(pixel-scroll-precision-mode 1)
;; Show dir/file.el instead of file.el<2> for duplicate buffer names
(setq uniquify-buffer-name-style 'forward)
;; Hide the icon toolbar and scrollbar
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; Persist minibuffer history across sessions
(savehist-mode 1)
;; Reopen files at last cursor position
(save-place-mode 1)
;; Track recently opened files (M-x recentf-open)
(recentf-mode 1)
;; Show available keybindings after pressing a prefix key
(setq which-key-idle-delay 0.5)
(which-key-mode 1)

;; macOS: Cmd as Meta, right Option free for special characters
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)
(setq mac-right-option-modifier 'none)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(unless (package-installed-p 'exec-path-from-shell)
  (package-refresh-contents)
  (package-install 'exec-path-from-shell))
;; Copy shell PATH into Emacs so GUI app finds tools (rust-analyzer, mise, etc.)
(exec-path-from-shell-initialize)

(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Remap all modes to tree-sitter variants, auto-download grammars on first use
(setq treesit-enabled-modes t)
(setq treesit-auto-install-grammar 'always)

;; evil-want-* must be set before loading evil
;; integration: basic bindings in core Emacs modes (help, minibuffer)
;; keybinding nil: skip non-core modes, evil-collection handles those instead
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(require 'evil)
(evil-mode 1)

;; Vim bindings for 100+ non-core modes (dired, magit, help, etc.)
(unless (package-installed-p 'evil-collection)
  (package-install 'evil-collection))
(evil-collection-init)

;; C-{h,j,k,l} for window movement (F1 replaces C-h as help prefix)
(evil-define-key '(normal visual) 'global (kbd "C-h") #'evil-window-left)
(evil-define-key '(normal visual) 'global (kbd "C-j") #'evil-window-down)
(evil-define-key '(normal visual) 'global (kbd "C-k") #'evil-window-up)
(evil-define-key '(normal visual) 'global (kbd "C-l") #'evil-window-right)

;; SPC as leader key in normal/visual mode
(evil-set-leader 'normal (kbd "SPC"))
(evil-set-leader 'visual (kbd "SPC"))

;; SPC f — file
(evil-define-key 'normal 'global (kbd "<leader>ff") #'find-file)
(evil-define-key 'normal 'global (kbd "<leader>fr") #'recentf-open)
(evil-define-key 'normal 'global (kbd "<leader>fs") #'save-buffer)

;; SPC b — buffer
(evil-define-key 'normal 'global (kbd "<leader>bb") #'switch-to-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bd") #'kill-current-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bn") #'next-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bp") #'previous-buffer)

;; SPC h — help
(evil-define-key 'normal 'global (kbd "<leader>hf") #'describe-function)
(evil-define-key 'normal 'global (kbd "<leader>hv") #'describe-variable)
(evil-define-key 'normal 'global (kbd "<leader>hk") #'describe-key)

;; SPC p — project
(evil-define-key 'normal 'global (kbd "<leader>pf") #'project-find-file)
(evil-define-key 'normal 'global (kbd "<leader>pp") #'project-switch-project)
(evil-define-key 'normal 'global (kbd "<leader>pg") #'project-find-regexp)

;; SPC — misc
(evil-define-key 'normal 'global (kbd "<leader>SPC") #'execute-extended-command)
(evil-define-key 'normal 'global (kbd "<leader>.") #'find-file)

;; LSP via eglot (built-in), auto-start for supported languages
(add-hook 'rust-ts-mode-hook #'eglot-ensure)

(unless (package-installed-p 'doom-themes)
  (package-install 'doom-themes))
(unless (package-installed-p 'catppuccin-theme)
  (package-install 'catppuccin-theme))
(setq catppuccin-flavor 'frappe)
(load-theme 'catppuccin t)
