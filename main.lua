local loginButton = get("loginButton")
local registerButton = get("registerButton")
local reloadButton = get("reloadButton")
local sendButton = get("sendButton")
local saveButton = get("settingSaveButton")

local usernameInput = get("usernameInput")
local passwordInput = get("passwordInput")

local registeredUsers = get("registeredUsers")

local accError = get("accError")
local msgError = get("msgError")
local usernameField = get("usernameField")

local messageInput = get("messageInput")
local regionSelection = get("regionSelection")

local messageHeaders = get("messageHeader", true)
local messageContents = get("messageContent", true)
local messageSubs = get("messageSub", true)

local apiEndpoint = "http://85.215.65.254:5000/"

local token = ""

function reloadMessages()
    local res = fetch({
        url = apiEndpoint .. "getmessages",
        method = "GET",
        headers = { ["Content-Type"] = "application/json" }
    })

    for index, msgObj in ipairs(res.messages) do      
        messageHeaders[index].set_content(msgObj.user)
        messageContents[index].set_content(msgObj.content)
        messageSubs[index].set_content(msgObj.region .. ", " .. msgObj.timestamp)
    end
end

function sendMessage()
    local message = messageInput.get_content()

    local res = fetch({
        url = apiEndpoint .. "sendmessage",
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        body = '{ "token": "' .. token .. '", "message": "' .. message ..'"}'
    })

    if res.success == true then
        for index, msgObj in ipairs(res.messages) do      
            messageHeaders[index].set_content(msgObj.user)
            messageContents[index].set_content(msgObj.content)
            messageSubs[index].set_content(msgObj.region .. ", " .. msgObj.timestamp)
        end

        msgError.set_content("")
        messageInput.set_content("")

    else
        msgError.set_content(res.reason)
    end
end

function login(loginData)
    token = loginData.token
    accError.set_content("")
    usernameField.set_content(loginData.username)

    usernameInput.set_content("")
    passwordInput.set_content("")
end

msgError.set_content("1")

reloadMessages()

msgError.set_content("2")

local res = fetch({
    url = apiEndpoint .. "pageload",
    method = "GET",
    headers = { ["Content-Type"] = "application/json" }
})
registeredUsers.set_content("Registered Users: " .. res.registered_users)


registerButton.on_click(function()
    local username = usernameInput.get_content()
    local password = passwordInput.get_content()

    local res = fetch({
        url = apiEndpoint .. "register",
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        body = '{ "username": "' .. username .. '", "password": "' .. password ..'"}'
    })
    if res.success == false then
        accError.set_content(res.reason)
    else
        login(res)
    end
end)

loginButton.on_click(function()
    local username = usernameInput.get_content()
    local password = passwordInput.get_content()

    local res = fetch({
        url = apiEndpoint .. "login",
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        body = '{ "username": "' .. username .. '", "password": "' .. password ..'"}'
    })
    if res.success == false then
        accError.set_content(res.reason)
    else
        login(res)
    end
end)

reloadButton.on_click(function()
    reloadMessages()
end)

sendButton.on_click(function()
    sendMessage()
end)

messageInput.on_submit(function()
    sendMessage()
end)

saveButton.on_click(function()
    local res = fetch({
        url = apiEndpoint .. "changesettings",
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        body = '{ "token": "' .. token .. '", "region": "' .. regionSelection.get_content() ..'"}'
    })
end)
