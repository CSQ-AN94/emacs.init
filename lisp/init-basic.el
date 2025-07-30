(when (eq system-type 'windows-nt)
  (add-hook 'emacs-startup-hook
    (lambda ()
      ;; 调用外部命令，切系统输入法到 US 英文 (00000409)
      (call-process "rundll32.exe" nil 0 nil
                    "user32.dll,LoadKeyboardLayout" "00000409" "1"))))



(setq wgrep-auto-save-buffer t)
(setq make-backup-files nil)

(server-mode 1)
(require 'server)
(unless (server-running-p)
  (server-start))

(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-item 10)

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

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))


(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :init (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
              history-length 1000
              savehist-additional-variables '(mark-ring
                                              global-mark-ring
                                              search-ring
                                              regexp-search-ring
                                              extended-command-history)
              savehist-autosave-interval 300)
  )




(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

(use-package simple
  :ensure nil
  :hook (after-init . size-indication-mode)
  :init
  (progn
    (setq column-number-mode t)
    ))



(provide 'init-basic)
