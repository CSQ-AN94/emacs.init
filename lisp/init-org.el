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
  (org-roam-db-autosync-mode)           ;; 启动时自动同步数据库
  (with-eval-after-load 'evil
    (dolist (kv '(("C-c n f" . org-roam-node-find)
                  ("C-c n i" . org-roam-node-insert)
                  ("C-c n c" . org-roam-capture)
                  ("C-c n l" . org-roam-buffer-toggle)
                  ("C-c n u" . org-roam-ui-mode)))
      (evil-define-key '(normal insert emacs)  ;; 三种 state
        global-map
        (kbd (car kv))
        (cdr kv)))))

  
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

;; (use-package org-roam-more
;;   :after org-roam
;;   :vc (:fetcher github :repo "gongshangzheng/org-roam-more"))

(setq org-hide-emphasis-markers nil)

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

    (setq-default org-download-heading-lvl nil
                  org-download-image-dir "./img"
                  ;; org-download-screenshot-method "screencapture -i %s"
                  org-download-screenshot-file (expand-file-name "screenshot.jpg" temporary-file-directory)))

;; LaTex 相关
(use-package org
      :defer t ;; 延迟加载
      :custom
      (org-highlight-latex-and-related '(native latex entities)) ;; LaTeX 高亮设置
      (org-pretty-entities t) ;; LaTeX 代码的 prettify
      (org-pretty-entities-include-sub-superscripts nil) ;; 不隐藏 LaTeX 的上下标更容易编辑
      (org-format-latex-options
       '(:foreground default :background default :scale 1.4 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers ("begin" "$1" "$" "$$" "\\(" "\\["))) ;; 增大公式预览的图片大小
      :config
      (add-hook 'org-mode-hook #'org-cdlatex-mode) ;; 打开 cdlatex
  )

(add-hook 'org-mode-hook #'org-cdlatex-mode) ;; 在 org-mode 中使用 cdlatex

  (setq org-highlight-latex-and-related '(native latex entities)) ;; LaTeX 语法高亮设置
  (setq org-pretty-entities t) ;; LaTeX 代码的 prettify
  (setq org-pretty-entities-include-sub-superscripts nil) ;; 不隐藏 LaTeX 的上下标更容易编辑

(defun my/insert-inline-OCDL ()
    (interactive)
    (insert "\\(") ;; 把 "\\(" 和 "\\)" 替换成 "$" 就能实现输入成对 "$" 的功能.
    (save-excursion (insert "\\)" )))

(define-key org-cdlatex-mode-map (kbd "$") 'my/insert-inline-OCDL)

(setq org-startup-with-inline-images t) ; 打开 Org 文件就显示图片
(add-hook 'after-save-hook #'org-display-inline-images) ; 保存自动刷新
  

;; ;; 等 org-cdlatex 加载完再绑键，避免被后面包裹
;; (with-eval-after-load 'org-cdlatex
;;   ;; 先确保没有全局性覆盖
;;   (define-key org-cdlatex-mode-map (kbd "$") nil)

;;   ;; 只在 insert 和 emacs state 里启用 `$ → my/insert-inline-OCDL`
;;   (evil-define-key '(insert emacs)   ; 目标 state
;;     org-cdlatex-mode-map            ; 目标 keymap（仅 org-cdlatex）
;;     (kbd "$")                       ; 绑定的按键
;;     #'my/insert-inline-OCDL))       ; 调用的函数

  ;; 快速编译数学公式
;; (use-package org-preview
;;     :load-path "orgpreview/" ; 需要手动从网盘或 https://github.com/karthink/org-preview/ 下载 org-preview.el 文件, 并置于 ~/.emacs.d/lisp/ 文件夹下
;;     ;; straight 用户用下一行取代上一行
;;     ;; :straight (:host github :repo "karthink/org-preview")
;;     :hook (org-mode . org-preview-mode))

(use-package org-fragtog
    :hook (org-mode . org-fragtog-mode))

;; 确保加载 Org 的 Markdown 导出后端
(with-eval-after-load 'org
  (require 'ox-md)
  ;; （可选）如果你想在自定义后端列表里也能看到 md
  (add-to-list 'org-export-backends 'md))


(require 'ob)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C . t)))  ;; 注意 C 要大写

(org-babel-do-load-languages
 'org-babel-load-languages
 '((java . t))) ;; 开启 Java

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C . t)      ;; 注意这里是大写 C
   (java . t)
   (python . t)
   (shell . t)))

(use-package ox-hugo
  :ensure t   ;Auto-install the package from Melpa
  :pin melpa  ;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
  :after ox)


;; (use-package org-roam
;;   :ensure t
;;   :init
;;   (setq org-roam-v2-ack t)        ;; 如果你用的是 Org-Roam v2
;;   :custom
;;   (org-roam-directory "g:/roam-notes")  ;; 改成你的笔记目录
;;   (org-roam-buffer-position 'right)  ;; 侧边栏在右侧，可选 'left
;;   (org-roam-buffer-width  0.33)      ;; 宽度比例或绝对列数
;;   :config
;;   (org-roam-setup))

;; (global-set-key (kbd "C-c b") #'org-roam-buffer-toggle)


;; ;;预览
;; (use-package org-roam
;;   :bind (("C-c n t" . org-roam-buffer-toggle)          ; 跟随光标自动切换
;;          ("C-c n p" . org-roam-buffer-display-dedicated)) ; 专用预览窗口
;;   :config
;;   (setq org-roam-mode-sections
;;         (list #'org-roam-backlinks-section        ; 默认就会带正文预览
;;               #'org-roam-reflinks-section)))

;; ;; 1. 安装并开启 org-preview-html（零配置即可导出 HTML 并用 xwidget 渲染）
;; (use-package org-preview-html
;;   :after org
;;   :custom
;;   ;; 用 xwidget 而不是 eww
;;   (org-preview-html-viewer 'xwidget)
;;   ;; 预览 HTML 存放临时目录
;;   (org-preview-html-export-dir (expand-file-name "html-preview/" user-emacs-directory))
;;   :bind
;;   ;; C-c p 预览当前文件；再按一次则关闭
;;   ("C-c p p" . org-preview-html-mode)
;;   ;; C-c P 导出 HTML 文件并弹出系统浏览器
;;   ("C-c p [" . (lambda ()
;;                (interactive)
;;                (org-preview-html-export)
;;                (browse-url-default-browser
;;                 (concat "file://" 
;;                         (expand-file-name
;;                          (file-name-base (buffer-file-name)) ".html"
;;                          org-preview-html-export-dir))))))


(provide 'init-org)
