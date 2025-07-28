(server-mode 1)
(require 'server)
(unless (server-running-p)
  (server-start))

(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-item 10)

(provide 'init-better-defaults)
