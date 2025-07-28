;; -*- lexical-binding: t -*-

(setq package-check-signature nil)

(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'init-basic)
(require 'init-packages)
(require 'init-tools)
(require 'init-completion)
(require 'init-func)

(require 'init-better-defaults)

(require 'init-keybindings)
(require 'init-ui)

(require 'init-style)
(require 'custom)

(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(load custom-file 'no-error 'no-message)


