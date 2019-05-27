-- use chooser interface to first select a list
-- then quickly append text to that list
-- imagined use case: books to read, movies to watch, etc.

-- other ideas:
-- database so i can track date added, date modified, type, etc.
-- could even add reviews after consuming said media?
-- https://www.sqlite.org/backup.html
-- http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki#sqlite3_open
-- http://lua.sqlite.org/index.cgi/artifact/8157f16fa6bd6d20
local obj = {}
obj.__index = obj

obj.name = "QuickAdd"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("QuickAdd")
obj.hotkeyShow = nil

local sqlite3 = hs.sqlite3

obj.db = sqlite3.open_memory()

obj.db:exec[[
  CREATE TABLE test (
    id        INTEGER PRIMARY KEY,
    content   VARCHAR
  );
]]

function obj:insertStmt(data)
  local insert_stmt = assert( obj.db:prepare("INSERT INTO test VALUES (NULL, ?)") )
  insert_stmt:bind_values(data)
  insert_stmt:step()
  insert_stmt:reset()
end

function obj:select()
  local select_stmt = assert( obj.db:prepare("SELECT * FROM test") )

  for row in select_stmt:nrows() do
      print(row.id, row.content)

    end
end

function obj:initDb()
  if not obj.db:isopen() then 
    obj.db = sqlite3.open_memory()
    obj.db:exec[[
    CREATE TABLE test (
        id        INTEGER PRIMARY KEY,
        content   VARCHAR
      );
    ]]

  else 
    obj.logger.e("DB already open")
  end
end

function obj:closeDb()
  if obj.db:isopen() then 
    obj.db:close()
  else 
    obj.logger.e("No DB to close")
  end
end

function obj:test()
  obj:insertStmt("Hello World")
  print("First:")
  obj:select()

  obj:insertStmt("Hello Lua")
  print("Second:")
  obj:select()

  obj:insertStmt("Hello Sqlite3")
  print("Third:")
  obj:select()
end

return obj