(require 'org-tempo)

(use-package org
  :pin melpa
  :ensure t)

(use-package org-contrib
  :pin nongnu)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d!/!)")
              (sequence "WAITING(w@/!)" "SOMEDAY(S)" "|" "CANCELLED(c@/!)" "MEETING(m)" "PHONE(p)"))))

(require 'org-checklist)

(setq org-log-done t)
(setq org-log-into-drawer t)

(global-set-key (kbd "C-c a") 'org-agenda)

(require 'init-func)  ;; 先把扫描函数加载进来
;; 关键：在真正调用 org-agenda 前，先动态设置 org-agenda-files
(with-eval-after-load 'org
  (advice-add
   'org-agenda :around
   (lambda (orig &rest args)
      (setq my/org--agenda-before-buffers (my/org--org-buffers)
             my/org--agenda-origin-buffer (current-buffer)) 
     (setq org-agenda-files (my/org--scan-all))
     (apply orig args))))

 (with-eval-after-load 'org-agenda
  ;; 退出 Agenda 时再清理，避免误杀当前编辑的 org 缓冲区
  (advice-add 'org-agenda-quit :after
              (lambda (&rest _)
                (when (and my/org--agenda-before-buffers my/org--agenda-origin-buffer)
                  (my/org--kill-new-org-buffers
                   my/org--agenda-before-buffers
                   my/org--agenda-origin-buffer))))) 

(setq org-agenda-span 'day)

(setq org-capture-templates
      '(("t" "Todo" entry (file (lambda () (buffer-file-name)))
         "* TODO [#B] %?\n  %i\n %U"
         :empty-lines 1)))

(global-set-key (kbd "C-c r") 'org-capture)

;; ---------- Org 专用“现代折行体验” ----------
(defun my/org-visual-setup ()
  (visual-line-mode 1)            ;; 软折行
  (setq-local truncate-lines nil) ;; 不截断
  (setq-local word-wrap nil)      ;; ★ 允许对无空格长串（1111…）在任意字符处折行
  (setq-local line-move-visual t) ;; j/k 或上下键按屏幕行走（配合 evil 更顺手）
  (org-indent-mode 1)
)
(add-hook 'org-mode-hook #'my/org-visual-setup)

;; org-download
(use-package org-download
    :ensure t
    :demand t
    :after org
    :config
    (add-hook 'dired-mode-hook 'org-download-enable)
    (setq org-download-screenshot-method "powershell -c Add-Type -AssemblyName System.Windows.Forms;$image = [Windows.Forms.Clipboard]::GetImage();$image.Save('%s', [System.Drawing.Imaging.ImageFormat]::Png)")
    (defun org-download-annotate-default (link)
      "Annotate LINK with the time of download."
      (make-string 0 ?\s))
    (setq org-image-actual-width nil)
    (setq-default org-download-heading-lvl nil
                  org-download-image-dir "./img"
                  ;; org-download-screenshot-method "screencapture -i %s"
                  org-download-screenshot-file (expand-file-name "screenshot.jpg" temporary-file-directory)))

;;;org-roam
(use-package org-roam
  :ensure t              ;; 自动安装
  :custom
  (org-roam-directory        "g:/roam-notes/")    ;; 默认笔记目录，提前手动创建好
  (org-roam-dailies-directory "daily/")           ;; 默认日记目录，上一目录的相对路径
  (org-roam-db-gc-threshold   most-positive-fixnum) ;; 提高性能
  :bind
  (("C-c n f" . org-roam-node-find)
   ;; 如果你的中文输入法会拦截非 ctrl 开头的快捷键，也可考虑类似如下的设置
   ;; ("C-c C-n C-f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n c" . org-roam-capture)
   ("C-c n l" . org-roam-buffer-toggle)  ;; 显示后链窗口
   ("C-c n u" . org-roam-ui-mode))       ;; 浏览器中可视化
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)     ;; 日记菜单
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:20}" 'face 'org-tag)))
  (require 'org-roam-dailies)            ;; 启用日记功能
  (org-roam-db-autosync-mode))           ;; 启动时自动同步数据库

(use-package org-roam-ui
  :ensure t              ;; 自动安装
  :after org-roam
  :custom
  (org-roam-ui-sync-theme    t)          ;; 同步 Emacs 主题
  (org-roam-ui-follow        t)          ;; 笔记节点跟随
  (org-roam-ui-update-on-save t))

(use-package org-transclusion
  :after org
  :hook (org-mode . org-transclusion-mode)  ;; 打开 Org 文件时自动启用
  :bind
  (("C-c t a" . org-transclusion-add)      ;; 添加 transclusion
   ("C-c t r" . org-transclusion-remove))) ;; 移除 transclusion

(use-package org-roam-more
  :after org-roam
  :vc (:fetcher github :repo "gongshangzheng/org-roam-more"))

(setq org-hide-emphasis-markers nil)

(provide 'init-org)
