# App configuration

## Log config

Location: `config/log.json`

```json
{"dbg": true/false, "log": true/false, "log_path": "path/to/logfile"}
```

- `dbg`: whether to print debug messages in the console
- `log`: whether to log queries to a file
- `log_path`: the path to the log file (relative to the current directory, absolute is recommended)

## Databases location config

Location: `cfg/dblocation.cfg`

```text
/path/to/databases
```

- This path in the file must point to the directory where the databases are stored. Each database is a subdirectory in this directory. (and must have a `ccdb.json` file in it)
