-- Patterns

local parse_globals = {}
parse_globals.SELECT_FROM = "^SELECT ([%a_,*%s*%*]+) FROM ([%a_]+)%s*.*;$"
parse_globals.SELECT_FROM_ONLY = "^SELECT ([%a_,*%s*]+) FROM ([%a_]+)%s*"
parse_globals.WHERE = "WHERE%s+(.*)%s*"
parse_globals.WHERE_PATTERN = "^([%a_]+)%s*([<>!=%%]+)%s*(.*)$"
parse_globals.SELECT_ORDER_BY = "ORDER%s+BY%s+([%a_,%s]+)"
parse_globals.SELECT_ORDER_BY_SINGLE = "([%a_]+)%s*([%a]*)"; -- check of ASC/DESC will be done in parser
parse_globals.SELECT_LIMIT = "LIMIT%s+(%d+)$"
parse_globals.INSERT_INTO = "^INSERT%s+INTO%s+([%a_]+)%s*(%([%s%a_,]+%))%s*VALUES%s+(.*);$"
parse_globals.INSERT_CLEANUP = "^,?%s*%((.*)$"
parse_globals.UPDATE = "^UPDATE%s+([%a_]+)%s+SET%s+(.*);$"
parse_globals.UPDATE_ONLY = "^UPDATE%s+([%a_]+)%s+SET%s+"
parse_globals.UPDATE_PART = "^([%a_]+)%s*=%s*(.*)"
parse_globals.DELETE = "^DELETE%s+FROM%s+([%a_]+)%s*(.*);$"
parse_globals.QUERY_TYPE = "^([%a]+)%s"
parse_globals.VALUE_TYPES = {
    STRING = "^'(.*)'$",
    FLOAT = "^(%-?%d+%.?%d*)$",
    INTEGER = "^(%-?%d+)$",
    BOOLEAN_TRUE = "^(TRUE)$",
    BOOLEAN_FALSE = "^(FALSE)$",
    NULL = "^(NULL)$"
}

parse_globals.NULL = {
    type = "null",
    value = nil
}; -- Used so we can differentiate between a NULL value and a missing value

return parse_globals
