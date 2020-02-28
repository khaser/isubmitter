# informatics submitter for vim
A [informatics](informatics.msk.ru) submitter plugin for vim

## Installation
- Install `curl`.
- Install `isubmitter` with your favorite vim plugin manager. 
If you use [`vim-plug`](https://github.com/junegunn/vim-plug):
If you use ['']

```
Plug 'khaser/isubmitter'
```

## Usage
- `<F4>` - Login to your account and submit your solution

When using the submit, this plugin will "guess" task id by the current file name. 
It should be in the following form:
- `~/C++/2020/..../task_id.cpp`
Task id you can see in the ulr on informatics
https://informatics.msk.ru/mod/statements/view3.php?chapterid=98 (task id = 98)
https://informatics.msk.ru/mod/statements/view3.php?id=32606&chapterid=3805#1 (task id = 3805)

