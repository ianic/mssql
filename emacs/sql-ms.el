(require 'sql)

(defcustom sql-conn ""
  "Default mssql connection."
  :type 'string
  :group 'SQL
  :safe 'stringp)

;; customize ms sql mode
(setq sql-ms-program "mssql.rb")
(setq sql-ms-options '())
(setq sql-ms-login-params '(conn))

(defun my-sql-comint-ms (product options)
  "Create comint buffer and connect to Microsoft SQL Server."
  ;; Put all parameters to the program (if defined) in a list and call
  ;; make-comint.
  (setq sql-conn
        (sql-get-login-ext "Connection: " sql-conn nil nil)
        )
  (let ((params options))
    (if (not (string= "" sql-conn))
        (setq params (append (list "-c" sql-conn) params)))
    (sql-comint product params)))

(sql-set-product-feature 'ms :sqli-comint-func 'my-sql-comint-ms)

;;sql mode hooks
(add-hook 'sql-mode-hook (lambda () 
                           (setq truncate-lines t)
                           (sql-highlight-ms-keywords)
                           (setq sql-send-terminator t)
                           (setq comint-process-echoes t)
                           (setq tab-width 2)))
(add-hook 'sql-interactive-mode-hook (lambda () 
                                       (setq truncate-lines t)
                                       (setq comint-process-echoes t)
                                       (text-scale-decrease 1)))

;; opening sql buffers
(defvar db-buffer "queries")
(defsubst db-get-buffer () (concat "*" db-buffer "*"))

(defun enter-db-mode ()
  (interactive)
  (sql-ms)
  (delete-other-windows)
  (split-window-horizontally)
  (switch-to-buffer-other-window (db-get-buffer) t)
  (sql-mode)
                                        ;(sql-highlight-ms-keywords)
  (swap-windows)
  (other-window -1)
  )

(global-set-key [f12] 'enter-db-mode)

(sql-set-product-feature 'ms :list-all ".find")
(sql-set-product-feature 'ms :list-table ".explain %s")
(sql-set-product-feature 'ms :prompt-regexp "^\\w*> ")
(sql-set-product-feature 'ms :completion-object 'sql-ms-completion-object)
(sql-set-product-feature 'ms :completion-column 'sql-ms-completion-object)

(defun sql-ms-completion-object (sqlbuf schema)
  (sql-redirect-value
   (sql-find-sqli-buffer)
   (concat
    "select s.name + '.' +	o.name"
    "	from sys.objects o"
    "	inner join sys.schemas s on o.schema_id = s.schema_id"
    "	where"
    "		type in ('P', 'V', 'U', 'TF', 'IF', 'FN' )"
    "		and  is_ms_shipped = 0"
    "\ngo"
    )
   "^| \\([a-zA-Z0-9_\.]+\\).*|$" 1)
)

;;fixing a function from sql.el
(defun sql-try-completion (string collection &optional predicate)
  (when sql-completion-sqlbuf
      (with-current-buffer sql-completion-sqlbuf
        (let ((schema (and (string-match "\\`\\(\\sw\\(:?\\sw\\|\\s_\\)*\\)[.]" string)
                           (downcase (match-string 1 string)))))

          ;; If we haven't loaded any object name yet, load local schema
          (unless sql-completion-object
            (sql-build-completions nil))

          ;; If they want another schema, load it if we haven't yet
          (when schema
            (let ((schema-dot (concat schema "."))
                  (schema-len (1+ (length schema)))
                  (names sql-completion-object)
                  has-schema)

              (while (and (not has-schema) names)
                (setq has-schema (and
                                  (>= (length (car names)) schema-len)
                                  (string= schema-dot
                                           (downcase (substring (car names)
                                                                0 schema-len))))
                      names (cdr names)))
              (unless has-schema
                (sql-build-completions schema)))))

        (cond
         ((not predicate)
          (try-completion string sql-completion-object))         
         ((eq predicate t)
          (all-completions string sql-completion-object))
         ((eq predicate 'lambda)
          (test-completion string sql-completion-object))
         ;;ianic added this condition
         ((eq predicate 'metadata)
          (test-completion string sql-completion-object))
         ((eq (car predicate) 'boundaries)
          (completion-boundaries string sql-completion-object nil (cdr predicate)))))))

(provide 'sql-ms)
