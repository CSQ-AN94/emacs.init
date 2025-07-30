(setq wgrep-auto-save-buffer t)
(setq make-backup-files nil)

(setq ring-bell-function 'ignore
      visible-bell nil)

(delete-selection-mode 1)

(global-auto-revert-mode 1)

(fset 'yes-or-no-p 'y-or-n-p)

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

(provide 'init-basic)
