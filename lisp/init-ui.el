;; 基础 UI
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; 光标 & 主题 & 字体
(add-to-list 'default-frame-alist '(cursor-type . (bar . 3)))

(use-package atom-one-dark-theme
  :ensure t
  :config
  (load-theme 'atom-one-dark t))

(set-face-attribute 'default nil :family "JetBrainsMono NF" :height 140)

(setq-default line-spacing 0.18)

(dolist (charset '(han cjk-misc kana bopomofo))
  (set-fontset-font t charset (font-spec :family "Noto Sans SC" :height 140)))

;;行号
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

;; 当前行高亮
(global-hl-line-mode 1)

;; 匹配括号
(electric-pair-mode t)
(add-hook 'prog-mode-hook #'show-paren-mode)


;;tabs
(use-package centaur-tabs
  :ensure t
  :demand t
  :init
  :config
  ;; 外观
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 40
        centaur-tabs-set-icons t 
        centaur-tabs-icon-type 'nerd-icons
        centaur-tabs-plain-icons t
     ;; centaur-tabs-set-bar 'under
     ;; x-underline-at-descent-line t
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "•"
        centaur-tabs-enable-buffer-reordering t)
  
  (centaur-tabs-mode t)
  ;; 关键：让 header-line（包含右侧空白区）跟主题的 mode-line 颜色对齐
  (centaur-tabs-headline-match)

  (defun centaur-tabs-buffer-groups ()
  "`centaur-tabs-buffer-groups' control buffers' group rules.

Group centaur-tabs with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `centaur-tabs-get-group-name' with project name."
  (list
   (cond
    ((or (string-equal "*" (substring (buffer-name) 0 1))
         (memq major-mode '(magit-process-mode
                            magit-status-mode
                            magit-diff-mode
                            magit-log-mode
                            magit-file-mode
                            magit-blob-mode
                            magit-blame-mode
                            )))
     "Emacs")
    ((derived-mode-p 'prog-mode)
     "Editing")
    ((derived-mode-p 'dired-mode)
     "Dired")
    ((memq major-mode '(helpful-mode
                        help-mode))
     "Help")
    ((memq major-mode '(org-mode
                        org-agenda-clockreport-mode
                        org-src-mode
                        org-agenda-mode
                        org-beamer-mode
                        org-indent-mode
                        org-bullets-mode
                        org-cdlatex-mode
                        org-agenda-log-mode
                        diary-mode))
     "OrgMode")
    (t
     (centaur-tabs-get-group-name (current-buffer))))))

  

  (add-hook 'dired-mode-hook       #'centaur-tabs-local-mode)
  (add-hook 'org-agenda-mode-hook  #'centaur-tabs-local-mode)

  (centaur-tabs-mode 1))


;; delimiters
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)


;;(keycast-mode-line-mode 0)
;;(setq keycast-mode-line-format "%2s %s") ; key + command 中间空格
;;(custom-set-faces
;; '(keycast-key ((t (:inherit mode-line :weight bold))))
;; '(keycast-command ((t (:inherit mode-line)))))

(use-package keycast
  :ensure t)
(add-to-list 'global-mode-string '("" keycast-mode-line))
(keycast-mode-line-mode t)


;; nerd-icons
(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode t))

(use-package simple
  :ensure nil
  :hook (after-init . size-indication-mode)
  :init
  (progn
    (setq column-number-mode t)))

(provide 'init-ui)
