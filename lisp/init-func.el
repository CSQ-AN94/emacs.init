;; 快速打开配置文件
(defun open-init-file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))


(use-package embark-consult)
(use-package wgrep)
(defun embark-export-write ()
  "Export the current vertico results to a writable buffer if possible.
Supports exporting consult-grep to wgrep, file to wdired, and consult-location to occur-edit"
  (interactive)
  (require 'embark)
  (require 'wgrep)
  (pcase-let ((`(,type . ,candidates)
               (run-hook-with-args-until-success 'embark-candidate-collectors)))
    (pcase type
      ('consult-grep     (let ((embark-after-export-hook #'wgrep-change-to-wgrep-mode))
                           (embark-export)))
      ('file             (let ((embark-after-export-hook #'wdired-change-to-wdired-mode))
                           (embark-export)))
      ('consult-location (let ((embark-after-export-hook #'occur-edit-mode))
                           (embark-export)))
      (x (user-error "embark category %S doesn't support writable export" x)))))


(defun my-c-mode-format-on-save ()
  (add-hook 'before-save-hook #'clang-format-buffer nil t))
(add-hook 'c-mode-common-hook #'my-c-mode-format-on-save)

(defun my-c-mode-format-on-save ()
  (add-hook 'before-save-hook #'clang-format-buffer nil t))
(add-hook 'c-mode-common-hook #'my-c-mode-format-on-save)


(defun awesome-tab-buffer-groups ()
  "`awesome-tab-buffer-groups' control buffers' group rules.
Group awesome-tab with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `awesome-tab-get-group-name' with project name."
  (list
   (cond
    ((or (string-equal "*" (substring (buffer-name) 0 1))
         (memq major-mode '(magit-process-mode
                            magit-status-mode
                            magit-diff-mode
                            magit-log-mode
                            magit-file-mode
                            magit-blob-mode
                            magit-blame-mode)))
     "Emacs")
    ((derived-mode-p 'eshell-mode)
     "EShell")
    ((derived-mode-p 'dired-mode)
     "Dired")
    ((memq major-mode '(org-mode org-agenda-mode diary-mode))
     "OrgMode")
    ((derived-mode-p 'eaf-mode)
     "EAF")
    (t
     (awesome-tab-get-group-name (current-buffer))))))


;;; org-agenda相关设置
;; 扫描的盘符（你要改就改这里）
(defvar my/org-agenda-roots '("E:/" "F:/" "G:/"))

;; 需要跳过的常见系统/巨型目录
(defvar my/org--exclude-dirs
  '("$RECYCLE.BIN" "System Volume Information" "Windows"
    "Program Files" "Program Files (x86)" "ProgramData"
    ".git" ".hg" ".svn" "node_modules" ".cache" ".venv" "venv"))

(defun my/org--excluded-dir-p (dir)
  (member (file-name-nondirectory (directory-file-name dir)) my/org--exclude-dirs))

(defun my/org--safe-collect (dir)
  "从 DIR 递归搜集 .org 文件，权限/IO 错误直接跳过。"
  (let (out)
    (when (file-directory-p dir)
      (condition-case nil
          (dolist (f (directory-files dir t "\\`[^.]")) ; 跳过 . 和 ..
            (cond
             ((file-directory-p f)
              (unless (my/org--excluded-dir-p f)
                (setq out (nconc out (my/org--safe-collect f)))))
             ((and (file-regular-p f)
                   (string-match-p "\\.org\\'" f))
              (push (expand-file-name f) out))))
        (error nil)))
    out))

(defun my/org--scan-all ()
  "扫描 E:/F:/G:/ 下所有 .org 文件（已排除系统目录）。"
  (delete-dups
   (apply #'append
          (mapcar (lambda (root)
                    (when (file-directory-p root)
                      (my/org--safe-collect root)))
                  my/org-agenda-roots))))



(provide 'init-func)
