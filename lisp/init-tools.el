(progn
  (defvar emax-root (concat (expand-file-name "~") "/emax"))
  (defvar emax-bin (concat emax-root "/bin"))
  (defvar emax-bin64 (concat emax-root "/bin64"))

  (setq exec-path (cons emax-bin exec-path))
  (setenv "PATH" (concat emax-bin ";" (getenv "PATH")))

  (setq exec-path (cons emax-bin64 exec-path))
  (setenv "PATH" (concat emax-bin64 ";" (getenv "PATH")))

  (setq emacsd-bin (concat user-emacs-directory "bin"))
  (setq exec-path (cons  emacsd-bin exec-path))
  (setenv "PATH" (concat emacsd-bin  ";" (getenv "PATH")))

  ;;可选安装msys64
  ;;下载地址: http://repo.msys2.org/mingw/sources/
  (setenv "PATH" (concat "C:\\msys64\\usr\\bin;C:\\msys64\\mingw64\\bin;" (getenv "PATH")))

  ;; (dolist (dir '("~/emax/" "~/emax/bin/" "~/emax/bin64/" "~/emax/lisp/" "~/emax/elpa/"))
  ;;   (add-to-list 'load-path dir))
  )


(require 'eglot)
(with-eval-after-load 'eglot
  ;; 忽略服务器提供的三种格式化功能
  (setq eglot-ignored-server-capabilities
        '(:documentFormattingProvider
          :documentRangeFormattingProvider
          :documentOnTypeFormattingProvider)))
(add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)

(use-package quickrun
  :ensure t
  :commands (quickrun)
  :init
  (quickrun-add-command "c++/c1z"
    '((:command . "g++")
      (:exec . ("%c -std=c++1z %o -o %e %s"
                "%e %a"))
      (:remove . ("%e")))
    :default "c++"))

(provide 'init-tools)
