 --- === MenubarTimer ===
---
--- A visual timer which is drawn over the MacOS menubar.
--- The timer is controlled using URLs.
--- hammerspoon://menubartimer?minutes=2
--- MenubarTimer accepts second[s], minute[s] and hour[s] as parameters and can be
--- mixed such as hammerspoon://menubartimer?hour=1&minutes=2&seconds=30
--- MenubarTimer:start() must be called to start listening for URLs
--- MenubarTimer:stop() can be called to cease the listening
---
--- Starting a new timer will safely override the previous timer

function stopPreviousBar()
    if menubarRect then
      menubarRect:delete()
    end
    if menubarAnimate then
      menubarAnimate:stop()
    end
  end
  
  function startMenubarTimer(duration)
    stopPreviousBar()
    local screen=hs.screen.mainScreen()
    local frame=screen:fullFrame()
    local menuh=frame.h-screen:frame().h
    local width=frame.w
    local rightCol={red=0.98,green=0.361,blue=0.49,alpha=0.5}
    local leftCol={red=0.416,green=0.51,blue=0.981,alpha=0.5}
  
    menubarRect=hs.drawing.rectangle(hs.geometry.rect(0,0,width,menuh))
    menubarRect:setFill(true)
    menubarRect:setBehaviorByLabels({hs.drawing.windowBehaviors.canJoinAllSpaces})
    menubarRect:show()
  
    local function generateRectangle(endCol)
      menubarRect:setSize({w=width,h=menuh})
      menubarRect:setFillGradient(leftCol,endCol,0)
    end
    generateRectangle(rightCol)
  
    local function interpolate(startCol,endCol,ratio)
      local newCol={}
  
      for k,v in pairs(startCol) do
        local dv=endCol[k]-v
        newCol[k]=v+dv*ratio
      end
  
      return newCol
    end
  
    local step=duration/width
    local startNS=hs.timer.absoluteTime()
    menubarAnimate=hs.timer.doUntil(function() return width==0 end, function()
      local curNS=hs.timer.absoluteTime()
      local ratio=1-(curNS-startNS)/(duration*1e9)
      width=math.max(0,frame.w*ratio)
      generateRectangle(interpolate(leftCol,rightCol,ratio))
    end,step)
  
    menubarAnimate:start()
  end
  
  function startListening()
    hs.urlevent.bind("menubartimer", function(_, params)
      local seconds=0
      local fieldsToSeconds={
        second=1,
        seconds=1,
        minute=60,
        minutes=60,
        hour=60*60,
        hours=60*60
      }
      for k,v in pairs(fieldsToSeconds) do
        if params[k] then
          seconds=seconds+params[k]*v
        end
      end
      if seconds==0 then
        hs.alert.show("menubartimer duration not specified")
      else
        startMenubarTimer(seconds)
      end
    end)
  end
  
  function stopListening()
    stopPreviousBar()
    hs.urlevent.bind("menubartimer", nil)
  end
  
  return {
    name='MenubarTimer',
    version=1,
    author='Tom Piercy',
    licence='MIT',
    start=startListening,
    stop=stopListening
  }