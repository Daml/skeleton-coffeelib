modules = []

# fake require
require = (name) ->
    paths = name.split("/")
    if paths[0] is "."
        name = paths.slice(1).join('/')
    if not modules[name]?
        throw new Error "module <#{name}> not loaded"
    return modules[name]

# register (to catch module.exports)
register = (name, module) =>
    falsemod = {}
    falsemod.exports = false
    module(falsemod, require)
    modules[name] = falsemod.exports;

# this special line separes header & footer
insertmodshere = true

# Export lib
if module?
    module.exports = require 'main'
else
    @MyLibrary = require 'main'
