;; -*- lexical-binding: t -*-

(setq package-check-signature nil)

(add-to-list 'load-path "~/.emacs.d/lisp/")

(setq custom-file (expand-file-name "lisp/custom.el" user-emacs-directory))
(load custom-file 'no-error 'no-message)

(require 'init-basic)

(require 'init-completion)

(require 'init-evil)

(require 'init-tools)

(require 'init-func)

(require 'init-packages)


(require 'init-keybindings)


(require 'init-ui)

(require 'init-org)

(require 'init-gdb)

(require 'init-style)
(require 'custom)

