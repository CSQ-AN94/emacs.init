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

(provide 'init-org)
