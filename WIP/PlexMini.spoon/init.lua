

--- PlexOverlay
--- Provides menubar applet to create and control floating plex miniplayer
--- NOT EVEN CLOSE TO STABLE, still in progress

--- Heavily based on:
--- === SDC Overcast ===
-- https://github.com/rsefer/dotfiles/blob/df890b0f2cfc9c6595037150413e9ae92a35d1d8/hammerspoon.symlink/Spoons/SDCOvercast.spoon/init.lua


--- PlexMini
-- [ ] add play pause to menubar
-- [ ] add info
-- [ ] add hide/show kill

local obj = {}
obj.__index = obj
obj.name = "PlexMini"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

obj.running = false

local plexWeb = 'https://app.plex.tv/desktop'
local viewWidth = 700
local viewHeight = 400
local iconSize = 14.0
local iconFull = hs.image.imageFromPath(script_path() .. 'images/overcast_black.pdf')
local icon = iconFull:setSize({ w = iconSize, h = iconSize })
local iconPlay = hs.image.imageFromPath(script_path() .. 'images/play.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPause = hs.image.imageFromPath(script_path() .. 'images/pause.pdf'):setSize({ w = iconSize, h = iconSize })

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function obj:togglePlayPause()
  obj.plexWebview:evaluateJavaScript('togglePlayPause();')
end

function obj:toggleWebview()
  if not obj.running then
    obj:start()
    obj.plexWebview:show():bringToFront(true)
  elseif obj.isShown then
    obj.plexWebview:hide()
    obj.isShown = false
  else
    obj.plexWebview.show():bringToFront(true)
		obj.plexWebview:hswindow():moveToScreen(hs.screen.primaryScreen()):focus()
    obj.isShown = true
  end
end

function obj:init()

  self.computerName = hs.host.localizedName()
  self.screenClass = 'large' -- assumes large iMac
  if string.match(string.lower(self.computerName), 'macbook') then
    self.screenClass = 'small'
  end

  self.isShown = false
  self.showProgressBar = true
  self.hideSpotify = true
  self.hideItunes = true

  self.plexToolbar = hs.webview.toolbar.new('myConsole', { { id = 'resetBrowser', label = 'Home', fn = function(t, w, i) self.plexWebview:url(plexWeb) end }, { id  = 'stop', label = 'Stop', fn = function() self:stop() end} })
    :sizeMode('small')
    :displayMode('label')

  self.plexInfoMenu = hs.menubar.new()
    :setClickCallback(obj.toggleWebview):setTitle("ⓘ")
  self.plexControlMenu = hs.menubar.new()
    :setClickCallback(obj.togglePlayPause):setIcon(iconPause)

    if self.plexMenu == nil then 
      self.plexMenu = hs.menubar.new()
        :setClickCallback(obj.toggleWebview)
        :setIcon(icon, true)
    end

  self.plexMenuFrame = self.plexMenu:frame()
  self.screenWidth = hs.screen.primaryScreen():currentMode().w
--   self.rect = hs.geometry.rect((self.plexMenuFrame.x + self.plexMenuFrame.w / 4) - (viewWidth / 2), self.plexMenuFrame.y, viewWidth, viewHeight)
  self.rect = hs.geometry.rect((self.screenWidth - viewWidth), self.plexMenuFrame.y, viewWidth, viewHeight + 50)

  self.plexJS = hs.webview.usercontent.new('plexoverlay')
 
  local injectFileResult = ''
  -- for line in io.lines(script_path() .. "inject.js") do injectFileResult = injectFileResult .. line end

  local injectJqueryResult = ''
  for line in io.lines(script_path() .. "plex.js") do injectJqueryResult = injectJqueryResult .. line end
  -- for line in io.lines(script_path() .. "jquery.min.js") do injectFileResult = injectFileResult .. line end

  -- localjsScript = "var thome = '" .. plexWeb .. "';" .. injectFileResult .. injectJqueryResult
  local localjsScript = "var thome = '" .. plexWeb .. "';" .. injectJqueryResult
  self.plexJS:injectScript({ source = localjsScript, mainFrame = false, injectionTime = 'documentEnd' })
    :setCallback(function(message)

      if message.body.page == 'home' or message.body.progress >= 1 then
        obj.plexInfoMenu:setIcon(nil)
        obj.plexControlMenu:setIcon(nil)
        obj.plexMenu:setIcon(icon, true)
        -- if message.body.podcast ~= nil then
        --   local notification = hs.notify.new({ title = 'Overcast', subTitle = 'Finished playing ' .. message.body.podcast.name })
        --   notification:setIdImage(iconFull)
        --   notification:send()
        --   hs.timer.doAfter(2.5, function() notification:withdraw() end)
        -- end
        if message.body.isFinished or (message.body.progress ~=nil and message.body.progress >= 1) then
          self.plexWebview:url(plexWeb)
        end
      elseif message.body.hasPlayer and message.body.hasPlayer == true then

        if message.body.isPlaying == true then

          obj.plexControlMenu:setIcon(iconPause)
          obj.plexMenu:setIcon(icon, false)

        else
          obj.plexControlMenu:setIcon(iconPlay)
          obj.plexMenu:setIcon(icon, true)
        end

        if obj.screenClass ~= 'small' and obj.showProgressBar and message.body.podcast.episodeTitle then

          local episodeString = message.body.podcast.name .. ' - ' .. message.body.podcast.episodeTitle

          menubarHeight = 50

					textColor = '000000'

					if hs.host.interfaceStyle() == 'Dark' then
						textColor = 'ffffff'
					end

          obj.menubarCanvas = hs.canvas.new({ x = 0, y = 0, h = menubarHeight, w = 250 })
            :appendElements({
              id = 'songProgress',
              type = 'rectangle',
              action = 'fill',
              frame = {
                x = '0%',
                y = menubarHeight - 2,
                h = 2,
                w = round(message.body.progress * 100, 2) .. '%'
              },
              fillColor = { ['hex'] = 'fc7e0f' }
            },
            {
              id = 'songText',
              type = 'text',
              text = episodeString:gsub(' ', ' '), -- replace 'normal space' character with 'en space'
              textSize = 14,
              textLineBreak = 'truncateTail',
              textColor = { ['hex'] = textColor },
              textFont = 'Courier',
              frame = { x = '0%', y = 1, h = '100%', w = '100%' }
            })

          obj.plexInfoMenu:setIcon(obj.menubarCanvas:imageFromCanvas(), false)
        end

      end

    end)

  self.plexWebview= hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, self.plexJS)
    :url(plexWeb)
    :allowTextEntry(true)
    :level(3)
    :shadow(true)
    :attachedToolbar(self.plexToolbar)
	  :windowCallback(function(action, webview, state)
			if action == 'closing' and state ~= true then
			    self.plexWebview:hide()
		        self.isShown = false
			end
    end)
    -- :windowStyle(
        -- hs.webview.windowMasks['titled'] |
        -- hs.webview.windowMasks['fullSizeContentView'] |
        -- hs.webview.windowMasks['resizable'] |
        -- hs.webview.windowMasks['closable'] |
        -- hs.webview.windowMasks['nonactivating']
        -- hs.webview.windowMasks['utility'] |
        -- hs.webview.windowMasks['HUD']
    -- )
end

function obj:stop()
  if self.plexWebview ~= nil then
    self.plexWebview:delete()
  end

  self.plexJS = nil

  -- if self.plexMenu then
  --   self.plexMenu:delete()
  -- end

  if self.plexInfoMenu then
    self.plexInfoMenu:delete()
  end

  if self.plexControlMenu then
    self.plexControlMenu:delete()
  end

  if self.plexToolbar then
    self.plexToolbar:delete()
  end

  self.plexToolbar = nil
  self.plexMenuFrame = nil

  self.running = false

  -- make sure we cleaned up everything
  -- edit: this is a bad idea
  -- for key, value in pairs(spoon.PlexOverlay) do 
  --   if key ~= "init" and value ~= "start" and value ~= "stop" and value ~= "running" then
  --     spoon.PlexOverlay[key] = nil
  --   end
  -- end
end

function obj:start()
  self:init()
  self.running = true
end

return obj