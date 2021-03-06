(add-to-list 'load-path "~/src/org-mode/lisp")

;; Using Cask for Package Management
(require 'cask "~/.cask/cask.el")
(cask-initialize)

;; Change C-x with C-n and C-c with C-i on Colemak layout
(keyboard-translate ?\C-n ?\C-x)
(keyboard-translate ?\C-x ?\C-n)
(keyboard-translate ?\C-i ?\C-c)
(keyboard-translate ?\C-c ?\C-i)

;; ==================================================
;;                 Basic Settings
;; ==================================================

(push "/usr/local/bin" exec-path)
(set-frame-font "Source Code Pro for Powerline-14")
(global-visual-line-mode t)
(delete-selection-mode t)
(blink-cursor-mode t)
(show-paren-mode t)
(setq backup-directory-alist `(("." . "~/.saves")))
(setq auto-save-default nil)
(setq inhibit-startup-message t)
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(fset 'yes-or-no-p 'y-or-n-p)
(electric-indent-mode t)
(setq redisplay-dont-pause t
      scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)
(when (window-system)
  (tooltip-mode -1)
  (set-fringe-style -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1))


;; ==================================================
;;               AUTO MODES
;; ==================================================

;; Ruby
(add-to-list 'auto-mode-alist '("Gemfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec\\'" . ruby-mode))

;; Web-mode
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.hbs\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.handlebars\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))

;; Emmet
(add-hook 'html-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'emmet-mode)


;; ==================================================
;;             REMCHI MODE MAPPINGS
;; ==================================================

;; Define my own keymap
(defvar remchi-mode-map (make-keymap) "my keys")

;; Cursor keys on home row
(define-key remchi-mode-map (kbd "M-e") 'next-line)
(define-key remchi-mode-map (kbd "M-u") 'previous-line)
(define-key remchi-mode-map (kbd "M-n") 'backward-char)
(define-key remchi-mode-map (kbd "M-i") 'forward-char)

;; EXPAND REGION
(define-key remchi-mode-map (kbd "C-o") 'er/expand-region)

;; ACE JUMP MODE
(define-key remchi-mode-map (kbd "C-c SPC") 'ace-jump-mode)

;; CUSTOM FUNCTIONS
(define-key remchi-mode-map (kbd "M-l") 'select-current-line)
(define-key remchi-mode-map (kbd "M-RET") 'line-above)
(define-key remchi-mode-map (kbd "C-S-y") 'duplicate-current-line-or-region)
(global-set-key (kbd "M-'") 'create-snippet)
(define-key remchi-mode-map (kbd "C-c r") 'rename-this-buffer-and-file)

;; PROJECTILE and HELM
(global-set-key (kbd "C-c h") 'helm-projectile)

;; ==================================================
;;             GLOBAL MAPPINGS
;; ==================================================

;; CUSTOM FUNCTIONS
(global-set-key [remap kill-region] 'cut-line-or-region)
(global-set-key [remap kill-ring-save] 'copy-line-or-region)


;; ==================================================
;;              PLUGINS and PACKAGES
;; ==================================================

;; DIRED SETTINGS
(require 'dired)
(setq dired-recursive-deletes (quote top))
(define-key dired-mode-map (kbd "f") 'dired-find-alternate-file)
(define-key dired-mode-map (kbd "^") (lambda ()
                                       (interactive)
                                       (find-alternate-file "..")))

;; YASNIPPET
(yas-global-mode t)

;; PROJECTILE
(projectile-global-mode)

;; IDO MODE
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
(setq ido-use-faces nil)

;; SAVEPLACE
(require 'saveplace)
(setq save-place-file (concat user-emacs-directory "saveplace.el"))
(setq-default save-place t)

;; AUTO-COMPLETE
(require 'auto-complete-config)
(ac-config-default)

;; SCSS MODE
(setq scss-compile-at-save nil)


;; ==================================================
;;              CUSTOM FUNCTIONS
;; ==================================================

(defun select-current-line ()
  "Selects the current line"
  (interactive)
  (end-of-line)
  (push-mark (line-beginning-position) nil t))

(defun line-above()
  "Inserts line above current one"
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(defun cut-line-or-region()
  "Kill current line if no region is active, otherwise kills region."
  (interactive)
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (kill-region (line-beginning-position) (line-beginning-position 2))))

(defun copy-line-or-region()
  "Copy current line if no region is active, otherwise copies region."
  (interactive)
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
    (kill-ring-save (line-beginning-position) (line-beginning-position 2))))

(defun duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times.
If there's no region, the current line will be duplicated. However, if
there's a region, all lines that region covers will be duplicated."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (beginning-of-visual-line)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

(defun create-snippet (filename)
  "Creates snippet file in ~/.emacs.d/snippets/<mode-name> folder"
  (interactive "s")
  (let ((mode (symbol-name major-mode)))
    (find-file (format "~/.emacs.d/snippets/%s/%s" mode filename))
    (snippet-mode)))

(defun rename-this-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))


;; ==================================================

;; Define my own minor mode and activate it
(define-minor-mode remchi-mode
  "A minor mode for my custom keys and functions"
  t " remchi" 'remchi-mode-map)
(remchi-mode t)

;; ==================================================
;;                  ORG MODE
;; ==================================================

(add-hook 'org-mode-hook
          (lambda()
            (set (make-local-variable 'electric-indent-functions)
                 (list (lambda(arg) 'no-indent)))))
(setq org-src-fontify-natively t)
(define-key global-map "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "DOING(i)" "|" "DONE(d)" "ARCHIVED")))
(setq org-todo-keyword-faces
  '(("TODO" . org-warning)
   ("DOING" . "yellow")
   ("NEXT" . "orange")
   ("DONE" . "green")
   ("ARCHIVED" . "blue")))
(setq org-agenda-custom-commands
      '(("d" todo "DOING")))
(setq org-log-done 'time)


;; ==================================================

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes (quote (sanityinc-tomorrow-eighties)))
 '(custom-safe-themes (quote ("628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'dired-find-alternate-file 'disabled nil)
