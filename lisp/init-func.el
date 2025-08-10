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


;; (defun awesome-tab-buffer-groups ()
;;   "`awesome-tab-buffer-groups' control buffers' group rules.
;; Group awesome-tab with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
;; All buffer name start with * will group to \"Emacs\".
;; Other buffer group by `awesome-tab-get-group-name' with project name."
;;   (list
;;    (cond
;;     ((or (string-equal "*" (substring (buffer-name) 0 1))
;;          (memq major-mode '(magit-process-mode
;;                             magit-status-mode
;;                             magit-diff-mode
;;                             magit-log-mode
;;                             magit-file-mode
;;                             magit-blob-mode
;;                             magit-blame-mode)))
;;      "Emacs")
;;     ((derived-mode-p 'eshell-mode)
;;      "EShell")
;;     ((derived-mode-p 'dired-mode)
;;      "Dired")
;;     ((memq major-mode '(org-mode org-agenda-mode diary-mode))
;;      "OrgMode")
;;     ((derived-mode-p 'eaf-mode)
;;      "EAF")
;;     (t
;;      (awesome-tab-get-group-name (current-buffer))))))

;; (defun centaur-tabs-buffer-groups ()
;;   (list
;;    (cond
;;     ((or (string-prefix-p "*" (buffer-name))
;;          (memq major-mode '(magit-process-mode
;;                             magit-status-mode
;;                             magit-diff-mode
;;                             magit-log-mode
;;                             magit-file-mode
;;                             magit-blob-mode
;;                             magit-blame-mode)))
;;      "Emacs")
;;     ((derived-mode-p 'eshell-mode) "EShell")
;;     ((derived-mode-p 'dired-mode)  "Dired")
;;     ((memq major-mode '(org-mode org-agenda-mode diary-mode)) "OrgMode")
;;     ((derived-mode-p 'eaf-mode) "EAF")
;;     (t (centaur-tabs-get-group-name (current-buffer))))))


;;; org-agenda相关设置
;; 扫描的盘符（你要改就改这里）
(defvar my/org-agenda-roots '("E:/ORG_SCHEDULE/" "G:/ORG_SCHEDULE/"))

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

(defun my/org--scan-all-elisp ()
  "原始 Elisp 版：扫描指定目录下所有 .org 文件（已排除系统目录）。"
  (delete-dups
   (apply #'append
          (mapcar (lambda (root)
                    (when (file-directory-p root)
                      (my/org--safe-collect root)))
                  my/org-agenda-roots))))

(defun my/org--scan-all ()
  "快速扫描 .org：优先用外部 rg/fd，没装时回落到纯 Elisp 实现。"
  (let ((roots my/org-agenda-roots))
    (cond
     ((executable-find "rg")
      ;; rg --files -g '*.org' ROOT1 ROOT2 ...
      (apply #'process-lines "rg" "--files" "-g" "*.org" roots))
     ((executable-find "fd")
      ;; fd --type f --extension org ROOT1 ROOT2 ...
      (apply #'process-lines "fd" "--type" "f" "--extension" "org" roots))
     (t
      ;; 回落到原来的 Elisp 版本
      (my/org--scan-all-elisp)))))

(defvar my/org--agenda-before-buffers nil)
(defvar my/org--agenda-origin-buffer nil)

(defun my/org--org-buffers ()
  "返回当前所有 .org 文件缓冲区（buffer 对象列表）。"
  (let (res)
    (dolist (b (buffer-list) (nreverse res))
      (when (and (buffer-file-name b)
                 (string-match-p "\\.org\\(\\.gpg\\)?\\'" (buffer-file-name b)))
        (push b res)))))

(defun my/org--kill-new-org-buffers (before origin)
  "只杀掉相对 BEFORE 新产生的 .org 缓冲区；保留可见/已改/原始缓冲区。"
  (dolist (b (buffer-list))
    (when (and (buffer-file-name b)
               (string-match-p "\\.org\\(\\.gpg\\)?\\'" (buffer-file-name b))
               (not (memq b before))                 ; 本次新开的
               (not (eq b origin))                   ; 回去的那个原缓冲区
               (not (get-buffer-window b 'visible))  ; 不杀可见的
               (not (buffer-modified-p b)))          ; 不杀已修改的
      (kill-buffer b))))

;;;------create a new org-roam file-------------
(require 'org)
(require 'org-id)            ;; 生成 ID
(require 'org-roam nil t)    ;; 有就用；没有也不报错

;; 你原来的综合搜索（含 tag）照旧
(global-set-key (kbd "C-c n f") #'org-roam-node-find)

;; 是否给文件名前缀时间戳（形如 20250810152300-xxx.org）
(defvar csq/org-roam-filename-use-ts-prefix t)

;; slug：优先用 org-roam 的实现，缺失就用简化版
(defun csq/slugify (s)
  (let* ((lower (downcase s))
         (spaces (replace-regexp-in-string "[[:space:]]+" "-" lower))
         (clean  (replace-regexp-in-string "[^a-z0-9-]" "" spaces)))
    (replace-regexp-in-string "-+" "-" clean)))

(defun csq/org-roam--title-to-slug (title)
  (cond
   ((fboundp 'org-roam-title-to-slug) (org-roam-title-to-slug title))
   ((fboundp 'org-roam--title-to-slug) (org-roam--title-to-slug title))
   (t (csq/slugify title))))

;; 在 org-roam-directory 下生成唯一路径
(defun csq/org-roam--unique-path (basename)
  (let* ((dir (file-name-as-directory
               (or (and (boundp 'org-roam-directory) org-roam-directory)
                   default-directory)))
         (i 1)
         (path (expand-file-name (concat basename ".org") dir)))
    (while (file-exists-p path)
      (setq path (expand-file-name (format "%s-%d.org" basename i) dir))
      (setq i (1+ i)))
    path))

(defun csq/org-roam-new-file (title)
  "总是按 TITLE 新建一个 org-roam 文件并打开：
- 文件名：时间戳-标题slug.org（可关闭时间戳）
- 文件头：:ID:、#+title、#+filetags
- 同名自动避让，不会跳到旧文件。"
  (interactive "sNew note title: ")
  (let* ((slug (csq/org-roam--title-to-slug title))
         (ts   (format-time-string "%Y%m%d%H%M%S"))
         (base (if csq/org-roam-filename-use-ts-prefix
                   (format "%s-%s" ts slug)
                 slug))
         (path (csq/org-roam--unique-path base)))
    (make-directory (file-name-directory path) t)
    (find-file path)
    (when (= (point-max) 1)                 ;; 只在新文件写入头部
      (let ((id (org-id-new)))
        (insert (format
                 ":PROPERTIES:\n:ID: %s\n:END:\n#+title: %s\n#+filetags:\n\n"
                 id title))
        (save-buffer)))
    ;; 同步进 org-roam 数据库（若可用）
    (when (featurep 'org-roam)
      (ignore-errors
        (if (fboundp 'org-roam-db-sync)
            (org-roam-db-sync)
          (when (fboundp 'org-roam-db-update-file)
            (org-roam-db-update-file)))))
    (message "Created: %s" path)))

(global-set-key (kbd "C-c n N") #'csq/org-roam-new-file)


(provide 'init-func)
