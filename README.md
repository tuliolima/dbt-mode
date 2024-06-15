# dbt-mode for Emacs

`dbt-mode` is a minor mode for runing dbt (data build tool) commands in Emacs.

## Installation

You can install `dbt-mode` from MELPA with the following: *TODO*

```emacs-lisp
(use-package dbt-mode
  :hook (sql-mode . dbt-mode)
  :init
  (setenv "DBT_TARGET" <target>)
  (setenv "DBT_USER" <user>))
```

## Usage

When opening a `.sql` file, `dbt-mode` will be enabled and will look for the dbt
project root (the directory with `dbt_project.yml` file). Then, it will prompt
for the path to the Python virtual environment to use for running dbt commands.

To use `dbt-mode`, you can run the following commands:

- `dbt-mode-run`: Execute the model corresponding to the current buffer.
    
## License

*TODO*
