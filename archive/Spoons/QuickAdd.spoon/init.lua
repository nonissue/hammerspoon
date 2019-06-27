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

obj.db = nil

local sqlite3 = hs.sqlite3

-- obj.db:exec[[
--   CREATE TABLE test (
--     id        INTEGER PRIMARY KEY,
--     content   VARCHAR,
--     type      VARCHAR,
--     url       VARCHAR,
--     rating    NULL
--   );
-- ]]

function obj:insertStmt(data, rating)
  rating = rating or "NULL"
  local insert_stmt = assert( obj.db:prepare("INSERT INTO test VALUES (NULL, strftime('%s','now'), ?, " .. rating .. ")") )
  insert_stmt:bind_values(data)
  insert_stmt:step()
  insert_stmt:reset()
end

function obj:select()
  local select_stmt = assert( obj.db:prepare("SELECT * FROM test") )

  for row in select_stmt:nrows() do
      print(row.id, row.created, row.content, row.rating)
    end
end

function obj:initDb()
  if not obj.db then
    obj.db = sqlite3.open_memory()
      obj.db:exec[[
        CREATE TABLE test (
          id        INTEGER PRIMARY KEY,
          created   VARCHAR,
          content   VARCHAR,
          rating    INTEGER
        );
      ]]
    else
      obj.logger.e("DB already open")
    end
  -- end
end

function obj:closeDb()
  if obj.db:isopen() then
    obj.db:close()
  else 
    obj.logger.e("No DB to close")
  end
end

function obj:test()
  -- obj:insertStmt("Hello World", "book", "https://test.com")
  obj:insertStmt("World", 5)
  print("\nFirst:")
  obj:select()

  -- obj:insertStmt("Lua", "web", "https://web.com")
  obj:insertStmt("Lua")
  print("\nSecond:")
  obj:select()

  print("\nThird:")
  -- obj:insertStmt("Sqlite3", "movie", "https://imdb.com/")
  obj:insertStmt("Tesssssssst")
  obj:select()
end

function obj:init()
  obj:initDb()
end

function obj:stop()
  obj:closeDb()
end

return obj