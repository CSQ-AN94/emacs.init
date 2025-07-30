;; 基础 UI
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; 光标 & 主题 & 字体
(add-to-list 'default-frame-alist '(cursor-type . (bar . 2)))
(set-cursor-color "#AEAFAD") 

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

(use-package centaur-tabs
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-set-icons t
        centaur-tabs-style "bar"))

(add-to-list 'load-path (expand-file-name "~/.emacs.d/awesome-tab"))
(require 'awesome-tab)
;;(awesome-tab-mode t)

;;icons
(use-package all-the-icons
  :ensure t)

(use-package all-the-icons-nerd-fonts
  :after all-the-icons
  :ensure t
  :config
  (all-the-icons-nerd-fonts-prefer))

(use-package nerd-icons
  :ensure t)

(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)


(keycast-mode-line-mode 0)
(setq keycast-mode-line-format "%2s %s") ; key + command 中间空格
(custom-set-faces
 '(keycast-key ((t (:inherit mode-line :weight bold))))
 '(keycast-command ((t (:inherit mode-line)))))

(provide 'init-ui)
