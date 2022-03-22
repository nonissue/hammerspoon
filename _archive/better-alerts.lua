local obj = {}
obj.__index = obj

obj.testCallbackFn = function(result)
    print("Callback Result: " .. result)
end

function obj.alert1()
    hs.dialog.alert(700, 200, obj.testCallbackFn, "TOTP Code", "942345", "Copy", "Fill", "Warning")
end

function obj.alert2()
    hs.dialog.alert(700, 400, testCallbackFn, "Message", "Informative Text", "Single Button")
end

return obj
