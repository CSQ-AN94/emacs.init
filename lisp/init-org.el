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
(setq org-agenda-files '("F:/ORG-mode/test.org"))

(require 'init-func)  ;; 先把扫描函数加载进来
;; 关键：在真正调用 org-agenda 前，先动态设置 org-agenda-files
(with-eval-after-load 'org
  (advice-add
   'org-agenda :around
   (lambda (orig &rest args)
     (setq org-agenda-files (my/org--scan-all))
     (apply orig args))))

(setq org-agenda-span 'day)

;;(setq org-capture-templates
  ;;    '(("t" "Todo" entry (file+headline "~/gtd.org" "Workspace")
    ;;     "* TODO [#B] %?\n  %i\n %U"
      ;;   :empty-lines 1)))

;;(global-set-key (kbd "C-c r") 'org-capture)

(provide 'init-org)
