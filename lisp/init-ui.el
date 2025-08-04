;; 基础 UI
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

(setq inhibit-startup-screen t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; 光标
(add-to-list 'default-frame-alist '(cursor-type . (bar . 3)))
;;  Normal（普通）模式：空心方块
(setq evil-normal-state-cursor   '(hollow))
;;  Insert State (I) — 3px
(setq evil-insert-state-cursor   '(bar . 3))
;;  Visual（可视）模式：空心方块，与普通相同，避免干扰
(setq evil-visual-state-cursor   '(hollow))
;;  Operator-Pending State (O) — 2px 下划线
(setq evil-operator-state-cursor '(hbar . 3))
;;  Motion-state
(setq evil-motion-state-cursor   '(hollow))

;; delimiters
(electric-pair-mode t)
(add-hook 'prog-mode-hook #'show-paren-mode)

(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; 主题 & 字体
;; (use-package doom-themes
;;   :ensure t
;;   :init
;;   (if (display-graphic-p)
;;       (load-theme 'doom-solarized-dark)
;;     (load-theme 'doom-tomorrow-night)))

;; (use-package doom-themes
;;   :ensure t
;;   :init
;;   (if (display-graphic-p)
;;       (load-theme 'doom-solarized-light)
;;     (load-theme 'doom-tomorrow-night)))

;; (set-face-attribute 'show-paren-match nil
;;                     :foreground "#61AFEF"  ; 匹配时，前景色
;;                     :background "#8BE9FD"         ; 不改背景
;;                     :weight     'bold)      ;
;;---
(use-package atom-one-dark-theme
  :ensure t
  :config
  (load-theme 'atom-one-dark t))

(set-face-attribute 'show-paren-match nil
                    :foreground  "#61AFEF" ; 匹配时，前景色
                    :background "#3E4452"         ; 不改背景
                    :weight     'bold)      ;


(set-face-attribute 'default nil :family "JetBrainsMono NF" :height 140)

(setq-default line-spacing 0.18)

(dolist (charset '(han cjk-misc kana bopomofo))
  (set-fontset-font t charset (font-spec :family "Noto Sans SC" :height 140)))

;;行号
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

;; 当前行高亮
(global-hl-line-mode 1)

;;tabs
(use-package centaur-tabs
  :ensure t
  :demand t
  :init
  :config
  ;; 外观
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 60
        centaur-tabs-bar-height 56
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


;;(keycast-mode-line-mode 0)
;;(setq keycast-mode-line-format "%2s %s") ; key + command 中间空格
;;(custom-set-faces
;; '(keycast-key ((t (:inherit mode-line :weight bold))))
;; '(keycast-command ((t (:inherit mode-line)))))

;; (use-package keycast
;;   :ensure t)
;; (add-to-list 'global-mode-string '("" keycast-mode-line))
;; (keycast-mode-line-mode t)


;; nerd-icons
(use-package nerd-icons
  :ensure t)

;; icon
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)  ; 图标背景对齐 Corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;;corfu buffer ui
(setq image-scaling-factor 0.7)
(add-hook 'corfu-mode-hook
  (lambda ()
    (when (boundp 'default-text-properties)
      (setq-local default-text-properties nil))
    (setq-local line-spacing 0)))


;; modeline
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

;; ;; 可视化空格/Tab/行尾空白
;; (setq whitespace-style '(face tabs spaces trailing space-mark tab-mark))
;; (setq whitespace-display-mappings
;;       '((space-mark 32 [183])      ; 空格显示为 · (U+00B7)
;;         (tab-mark   9  [187 9])))  ; Tab 显示为 »[Tab]
;; (global-whitespace-mode 0)
;;---------
;; (setq whitespace-style '(face tabs spaces trailing space-mark tab-mark))
;; (setq whitespace-display-mappings
;;       '((space-mark 32 [183])
;;         (tab-mark   9  [187 9])))

;; (defun my/whitespace-when-selecting ()
;;   (if (use-region-p)
;;       (unless whitespace-mode (whitespace-mode 1))
;;     (when whitespace-mode (whitespace-mode -1))))

;; (add-hook 'activate-mark-hook   #'my/whitespace-when-selecting)
;; (add-hook 'deactivate-mark-hook #'my/whitespace-when-selecting)
;; (add-hook 'post-command-hook    #'my/whitespace-when-selecting)



;;--------lsp mode----------
;; (setq lsp-eldoc-enable-hover nil)
;; (setq lsp-semantic-tokens-enable nil)
;; (with-eval-after-load 'lsp-mode
;;   (setq lsp-semantic-tokens-enable nil)
;;   ;; 如果不想要面包屑
;;   (setq lsp-headerline-breadcrumb-enable nil))
;; (setq lsp-ui-doc-enable nil)
;; ;; 关闭 lsp-ui-doc 和 sideline，但保留 peek 和 imenu
;; (with-eval-after-load 'lsp-ui
;;   (setq lsp-ui-doc-enable    nil
;;         lsp-ui-sideline-enable nil
;;         ;; 想关闭 peek、imenu 就把下面也设为 nil
;;         lsp-ui-peek-enable   nil
;;         lsp-ui-imenu-enable  nil))
;; (with-eval-after-load 'lsp-mode
;;   (setq lsp-semantic-tokens-enable nil))



(provide 'init-ui)
