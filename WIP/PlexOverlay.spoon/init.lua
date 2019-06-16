-- https://github.com/rsefer/dotfiles/blob/df890b0f2cfc9c6595037150413e9ae92a35d1d8/hammerspoon.symlink/Spoons/SDCOvercast.spoon/init.lua

--- === SDC Overcast ===

--- Plex 
-- [ ] add play pause to menubar
-- [ ] add info
-- [ ] add hide/show kill

local obj = {}
obj.__index = obj
obj.name = "Plex"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local plexWeb = 'https://plex.tv/web'
local viewWidth = 480
local viewHeight = 320
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
  obj.overcastWebview:evaluateJavaScript('togglePlayPause();')
end

function obj:toggleWebview()
  if obj.isShown then
    obj.Plex:hide()
    obj.isShown = false
  else
    obj.Plex:show():bringToFront(true)
		obj.Plex:hswindow():moveToScreen(hs.screen.primaryScreen()):focus()
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

  self.plexToolbar = hs.webview.toolbar.new('myConsole', { { id = 'resetBrowser', label = 'Home', fn = function(t, w, i) self.Plex:url(plexWeb) end } })
    :sizeMode('small')
    :displayMode('label')

  self.plexInfoMenu = hs.menubar.new()
    :setClickCallback(obj.toggleWebview):setTitle("ⓘ")
  self.plexControlMenu = hs.menubar.new()
    :setClickCallback(obj.togglePlayPause):setIcon(iconPause)

  self.plexMenu = hs.menubar.new()
    :setClickCallback(obj.toggleWebview)
    :setIcon(icon, true)

  self.plexMenuFrame = self.plexMenu:frame()
  self.screenWidth = hs.screen.primaryScreen():currentMode().w
--   self.rect = hs.geometry.rect((self.plexMenuFrame.x + self.plexMenuFrame.w / 4) - (viewWidth / 2), self.plexMenuFrame.y, viewWidth, viewHeight)
  self.rect = hs.geometry.rect((self.screenWidth - viewWidth), self.plexMenuFrame.y, viewWidth, viewHeight)

  self.plexJS = hs.webview.usercontent.new('idhsovercastwebview')
 

  local injectFileResult = ''
  for line in io.lines(script_path() .. "inject.js") do injectFileResult = injectFileResult .. line end

  localjsScript = "var thome = '" .. plexWeb .. "';" .. injectFileResult
  self.plexJS:injectScript({ source = localjsScript, mainFrame = true, injectionTime = 'documentEnd' })
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
          self.Plex:url(plexWeb)
        end
      elseif message.body.hasPlayer and message.body.hasPlayer == true then

        if message.body.isPlaying == true then

          obj.plexControlMenu:setIcon(iconPause)
          obj.plexMenu:setIcon(icon, false)

          -- if obj.hideSpotify then
          --   if hs.spotify.isPlaying() then
          --     hs.spotify.pause()
          --   end
          -- end

          if obj.hideItunes then
            if hs.itunes.isPlaying() then
              hs.itunes.pause()
            end
          end

        else
          obj.plexControlMenu:setIcon(iconPlay)
          obj.plexMenu:setIcon(icon, true)
        end

        if obj.screenClass ~= 'small' and obj.showProgressBar and message.body.podcast.episodeTitle then

          local episodeString = message.body.podcast.name .. ' - ' .. message.body.podcast.episodeTitle

          menubarHeight = 22

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

  self.Plex = hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, self.plexJS)
    :url(plexWeb)
    :allowTextEntry(true)
    :level(3)
    :shadow(true)
    -- :attachedToolbar(self.plexToolbar)
	:windowCallback(function(action, webview, state)
			if action == 'closing' and state ~= true then
			    self.Plex:hide()
		        self.isShown = false
			end
    end)
    -- :magnification(2)
    :windowStyle(
        hs.webview.windowMasks['titled'] |
        hs.webview.windowMasks['fullSizeContentView'] |
        -- hs.webview.windowMasks['resizable'] |
        hs.webview.windowMasks['closable'] |
        hs.webview.windowMasks['utility'] |
        hs.webview.windowMasks['HUD']
    )
    

end

return obj