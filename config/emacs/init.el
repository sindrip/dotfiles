;;; -*- lexical-binding: t; -*-

(add-to-list 'initial-frame-alist '(fullscreen . fullheight))

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
(fido-vertical-mode 1)

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
(setq evil-want-C-u-scroll t)
(setq evil-undo-system 'undo-redo)
(evil-mode 1)

;; Remap all modes to tree-sitter variants, auto-download grammars on first use
(setq treesit-enabled-modes t)
(setq treesit-auto-install-grammar 'always)

(unless (package-installed-p 'magit)
  (package-install 'magit))

;; LSP via eglot (built-in), auto-start for supported languages
(add-hook 'rust-ts-mode-hook #'eglot-ensure)

(unless (package-installed-p 'doom-themes)
  (package-install 'doom-themes))
(unless (package-installed-p 'catppuccin-theme)
  (package-install 'catppuccin-theme))
(setq catppuccin-flavor 'frappe)
(load-theme 'catppuccin t)

(unless (package-installed-p 'nerd-icons)
  (package-install 'nerd-icons))
(unless (package-installed-p 'doom-modeline)
  (package-install 'doom-modeline))
(doom-modeline-mode 1)

(set-fontset-font t 'symbol "Symbols Nerd Font Mono" nil 'prepend)
