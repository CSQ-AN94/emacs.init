;; -*- lexical-binding: t -*-

(setq package-check-signature nil)

(add-to-list 'load-path "~/.emacs.d/lisp/")

(setq custom-file (expand-file-name "lisp/custom.el" user-emacs-directory))
(load custom-file 'no-error 'no-message)

(require 'init-basic)

(require 'init-func)
(require 'init-packages)

(require 'init-evil)

(require 'init-completion)

(require 'init-tools)


(require 'init-keybindings)


(require 'init-ui)

(require 'init-org)
(require 'init-latex)
(add-to-list 'auto-mode-alist '("\\.tex\\'" . fundamental-mode))

(require 'init-gdb)

(require 'init-style)
(require 'custom)


;; (setq debug-on-quit t)  ; 启用 C-g 中断时进入调试
;; (setq gc-cons-threshold 100000000)  ; 提高 GC 阈值减少停顿

