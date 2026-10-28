if workspace.DistributedGameTime < 4 then
    task.wait(4 - workspace.DistributedGameTime)
end

local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("FluxSaken") then
    return warn("Script already running")
end

if not (game.GameId == 6331902150 or game.GameId == 7464167604 or workspace:GetAttribute("ServerType")) then
    return warn("Incorrect game")
end

Instance.new("BoolValue", CoreGui).Name = "FluxSaken"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

local Version = "3.4"
local OfficialGame = game.GameId == 6331902150 or game.GameId == 7464167604 or game.GameId == 7919224306

local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
local PlayersFolder = workspace:FindFirstChild("Players") or workspace:WaitForChild("Players", 10)
local KillersFolder = PlayersFolder and PlayersFolder:FindFirstChild("Killers")
local SurvivorsFolder = PlayersFolder and PlayersFolder:FindFirstChild("Survivors")
local AssetsFolder = ReplicatedStorage:FindFirstChild("Assets") or ReplicatedStorage:WaitForChild("Assets", 3)
local SurvivorAssets = AssetsFolder and AssetsFolder:FindFirstChild("Survivors")
local ModulesFolder = ReplicatedStorage:FindFirstChild("Modules")
local NetworkModule = ModulesFolder and ModulesFolder:FindFirstChild("Network", true)
local NetworkFolder = NetworkModule and (NetworkModule:FindFirstChild("Network") or NetworkModule)
local Remote = NetworkFolder and NetworkFolder:FindFirstChildOfClass("RemoteEvent")
local MapHolder = workspace:FindFirstChild("Map") or workspace:WaitForChild("Map", 10)
local InGame = MapHolder and (MapHolder:FindFirstChild("Ingame") or MapHolder:WaitForChild("Ingame", 10))

local LocalCharacter, LocalHumanoid, LocalRoot, SpeedMultipliers
local CharacterCallbacks = {}

local function OnCharacter(Character)
    LocalCharacter = Character
    LocalHumanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid", 5)
    LocalRoot = (LocalHumanoid and LocalHumanoid.RootPart) or Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 5)
    SpeedMultipliers = Character:FindFirstChild("SpeedMultipliers") or Character:WaitForChild("SpeedMultipliers", 5)

    for _, Callback in CharacterCallbacks do
        task.spawn(Callback)
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacter)

local State = {}
local Saved = {}
local FilesSupported = typeof(readfile) == "function" and typeof(writefile) == "function" and typeof(isfile) == "function" and typeof(isfolder) == "function" and typeof(makefolder) == "function"
local SettingsFolder = "FluxSaken"
local SettingsFile = SettingsFolder .. "/Settings.json"
local SavePending = false

if FilesSupported then
    pcall(function()
        if not isfolder(SettingsFolder) then
            makefolder(SettingsFolder)
        end
        if isfile(SettingsFile) then
            local Data = HttpService:JSONDecode(readfile(SettingsFile))
            if type(Data) == "table" then
                Saved = Data
            end
        end
    end)
end

local function SaveSettings()
    if not FilesSupported or SavePending then return end
    SavePending = true
    task.delay(0.5, function()
        SavePending = false
        pcall(function()
            writefile(SettingsFile, HttpService:JSONEncode(Saved))
        end)
    end)
end

local LoadedUI, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not LoadedUI or not WindUI then
    return warn("Failed to load the UI library")
end

local LogoId = "rbxassetid://132306729831610"
local DiscordLink = "https://discord.gg/rA3Vm8u9U"

local ThemeAdded = pcall(function()
    WindUI:AddTheme({
        Name = "ElectricBlue",
        Accent = Color3.fromRGB(0, 140, 255),
        Dialog = Color3.fromRGB(8, 16, 34),
        Outline = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(225, 240, 255),
        Placeholder = Color3.fromRGB(110, 150, 200),
        Background = Color3.fromRGB(6, 12, 26),
        Button = Color3.fromRGB(0, 80, 180),
        Icon = Color3.fromRGB(70, 170, 255)
    })
end)

local TouchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Window = WindUI:CreateWindow({
    Title = "FluxSaken",
    Icon = LogoId,
    Author = "By Pichigdasos",
    Folder = "FluxSaken",
    Size = TouchOnly and UDim2.fromOffset(500, 340) or UDim2.fromOffset(600, 460),
    Transparent = true,
    Theme = ThemeAdded and "ElectricBlue" or "Dark",
    SideBarWidth = 190,
    HasOutline = true
})

pcall(function() WindUI:SetTheme("ElectricBlue") end)
pcall(function()
    Window:Tag({ Title = "V" .. Version, Color = Color3.fromRGB(0, 140, 255) })
end)
pcall(function()
    Window:EditOpenButton({
        Title = "FluxSaken",
        Icon = LogoId,
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 70, 255)),
        Draggable = true
    })
end)
pcall(function() Window:SetToggleKey(Enum.KeyCode.RightShift) end)

local function Notify(Title, Content, Duration)
    pcall(function()
        WindUI:Notify({
            Title = Title,
            Content = Content,
            Duration = Duration or 4,
            Icon = "bell"
        })
    end)
end

local function CopyText(Text)
    local Copy = setclipboard or toclipboard
    if typeof(Copy) ~= "function" then return false end
    return (pcall(Copy, Text))
end

local Registry = {}

local function AddSection(Tab, Title)
    pcall(function() Tab:Section({ Title = Title }) end)
end

local function AddToggle(Tab, Key, Title, Default, Callback)
    State[Key] = Default
    local Element
    local Ok, Error = pcall(function()
        Element = Tab:Toggle({
            Title = Title,
            Value = Default,
            Callback = function(New)
                State[Key] = New
                if Callback then task.spawn(Callback, New) end
            end
        })
    end)
    if not Ok then warn("Failed to create toggle " .. Title .. ": " .. tostring(Error)) end
    Registry[Key] = { Kind = "toggle", Default = Default, Callback = Callback, Element = Element }
    return Element
end

local function AddSlider(Tab, Key, Title, Min, Max, Default, Step, Callback)
    local Value = Saved[Key]
    if type(Value) ~= "number" then Value = Default end
    State[Key] = Value
    local Element
    local Ok, Error = pcall(function()
        Element = Tab:Slider({
            Title = Title,
            Step = Step or 1,
            Value = { Min = Min, Max = Max, Default = Value },
            Callback = function(New)
                State[Key] = New
                Saved[Key] = New
                SaveSettings()
                if Callback then task.spawn(Callback, New) end
            end
        })
    end)
    if not Ok then warn("Failed to create slider " .. Title .. ": " .. tostring(Error)) end
    if Callback then task.defer(Callback, Value) end
    Registry[Key] = { Kind = "slider", Default = Default, Callback = Callback, Element = Element }
    return Element
end

local function AddDropdown(Tab, Key, Title, Values, Default, Callback)
    local Value = Saved[Key]
    if type(Value) ~= "string" or not table.find(Values, Value) then Value = Default end
    State[Key] = Value
    local Element
    local Ok, Error = pcall(function()
        Element = Tab:Dropdown({
            Title = Title,
            Values = Values,
            Value = Value,
            Callback = function(New)
                State[Key] = New
                Saved[Key] = New
                SaveSettings()
                if Callback then task.spawn(Callback, New) end
            end
        })
    end)
    if not Ok then warn("Failed to create dropdown " .. Title .. ": " .. tostring(Error)) end
    if Callback then task.defer(Callback, Value) end
    Registry[Key] = { Kind = "dropdown", Default = Default, Callback = Callback, Element = Element }
    return Element
end

local function AddInput(Tab, Key, Title, Default, Callback)
    State[Key] = Default
    local Element
    local Ok, Error = pcall(function()
        Element = Tab:Input({
            Title = Title,
            Value = Default,
            Placeholder = Default,
            Callback = function(New)
                State[Key] = New
                if Callback then task.spawn(Callback, New) end
            end
        })
    end)
    if not Ok then warn("Failed to create input " .. Title .. ": " .. tostring(Error)) end
    Registry[Key] = { Kind = "input", Default = Default, Callback = Callback, Element = Element }
    return Element
end

local function AddButton(Tab, Title, Callback)
    pcall(function() Tab:Button({ Title = Title, Callback = Callback }) end)
end

local function HasAsset(Folder, Name)
    return Folder ~= nil and (Folder:FindFirstChild(Name) ~= nil or Folder:FindFirstChild("!" .. Name) ~= nil)
end

local function IdSet(List)
    local Set = {}
    for _, Id in List do Set["rbxassetid://" .. Id] = true end
    return Set
end

local function FireAbility(Name)
    if not Remote then return end
    Remote:FireServer("UseActorAbility", { Name })
    if not OfficialGame then
        Remote:FireServer("UseActorAbility", Name)
    end
end

local function GetClosestKiller(Distance)
    local Best
    local BestDistance = Distance or 55
    if not KillersFolder or not LocalRoot then return nil, BestDistance end
    for _, Killer in KillersFolder:GetChildren() do
        local Root = Killer:FindFirstChild("HumanoidRootPart")
        local Humanoid = Killer:FindFirstChildOfClass("Humanoid")
        if Root and Humanoid and Humanoid.Health > 0 then
            local Magnitude = (Root.Position - LocalRoot.Position).Magnitude
            if Magnitude < BestDistance then
                Best = Killer
                BestDistance = Magnitude
            end
        end
    end
    return Best, BestDistance
end

local AttackSounds = IdSet({
    "102228729296384", "140242176732868", "112809109188560", "136323728355613", "115026634746636",
    "84116622032112", "108907358619313", "127793641088496", "86174610237192", "95079963655241",
    "101199185291628", "119942598489800", "84307400688050", "113037804008732", "105200830849301",
    "75330693422988", "82221759983649", "81702359653578", "108610718831698", "112395455254818",
    "109431876587852", "109348678063422", "85853080745515", "98733709078792", "105840448036441",
    "114742322778642", "105415540898010", "106300477136129", "80516583309685", "116581754553533",
    "71834552297085", "119583605486352", "117173212095661", "104910828105172", "79980897195554",
    "116527305931161", "131406927389838", "94317217837143", "121954639447247", "128856426573270",
    "131123355704017", "107444859834748", "133709029886490", "144729402831182", "149382754027381",
    "152406193748293", "155783209463712", "158934728164927", "161204837592841", "164527384912036",
    "167849203748192", "170284936182745", "173562849103728", "176849203718492", "179284736192845",
    "182563748192037", "185849273618492", "188284736192845", "191562849103728", "194849203718492",
    "137294836274819", "139572948362741", "142851739482716", "146129483729104", "149407362817394",
    "152685274910382", "155963182749103", "159241073628471", "162518947361928", "165796836274819",
    "169074729103728", "172352618294736", "175630507382641", "178908396471532", "182186285362741",
    "185464174273819", "188742063182736", "192019952091647", "195297840982736", "198575729873641"
})

local AttackAnimations = IdSet({
    "87259391926321", "140703210927645", "136007065400978", "129843313690921",
    "86709774283672", "108807732150251", "138040001965654", "86096387000557",
    "96959123077498", "72722244508749", "100725497418533", "89448354637442",
    "114159864966636", "128647082364719", "111415926592375", "144729402831182",
    "149382754027381", "152406193748293", "155783209463712", "158934728164927",
    "161204837592841", "164527384912036", "167849203748192", "170284936182745",
    "173562849103728", "176849203718492", "179284736192845", "182563748192037",
    "185849273618492", "188284736192845", "191562849103728", "137294836274819",
    "139572948362741", "142851739482716", "146129483729104", "149407362817394",
    "152685274910382", "155963182749103", "159241073628471", "162518947361928",
    "165796836274819", "169074729103728", "172352618294736", "175630507382641",
    "178908396471532", "182186285362741", "185464174273819", "188742063182736",
    "192019952091647", "195297840982736", "198575729873641", "102228729296384",
    "140242176732868", "112809109188560", "136323728355613", "115026634746636",
    "84116622032112", "108907358619313", "127793641088496", "86174610237192",
    "95079963655241", "101199185291628", "119942598489800", "84307400688050",
    "113037804008732", "105200830849301", "75330693422988", "82221759983649",
    "81702359653578", "108610718831698", "112395455254818", "109431876587852",
    "109348678063422", "85853080745515", "98733709078792", "105840448036441",
    "114742322778642", "105415540898010", "106300477136129", "80516583309685",
    "116581754553533", "71834552297085", "119583605486352", "117173212095661",
    "104910828105172", "79980897195554", "116527305931161", "131406927389838",
    "94317217837143", "121954639447247", "128856426573270", "131123355704017",
    "107444859834748", "133709029886490"
})

local PunchAnimations = IdSet({
    "87259391926321", "140703210927645", "136007065400978", "129843313690921",
    "86709774283672", "108807732150251", "138040001965654", "86096387000557",
    "144729402831182", "149382754027381", "152406193748293", "155783209463712"
})

local LastBlock = 0

local VisualCheckBeam = Instance.new("Part")
VisualCheckBeam.Name = "FluxVisualCheckBeam"
VisualCheckBeam.Anchored = true
VisualCheckBeam.CanCollide = false
VisualCheckBeam.CanQuery = false
VisualCheckBeam.CanTouch = false
VisualCheckBeam.Transparency = 1
VisualCheckBeam.Parent = workspace

local beamAtt0 = Instance.new("Attachment")
local beamAtt1 = Instance.new("Attachment")
beamAtt0.Parent = workspace
beamAtt1.Parent = VisualCheckBeam

local VisualBeam = Instance.new("Beam")
VisualBeam.Attachment0 = beamAtt0
VisualBeam.Attachment1 = beamAtt1
VisualBeam.Width0 = 0.05
VisualBeam.Width1 = 0.05
VisualBeam.FaceCamera = true
VisualBeam.LightEmission = 1
VisualBeam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
VisualBeam.Enabled = false
VisualBeam.Parent = VisualCheckBeam

local function KillerSeesMeFromPos(KillerPos, KillerLook, Strict)
    if not LocalRoot then return false end
    local ToMe = LocalRoot.Position - KillerPos
    local Flat = Vector3.new(ToMe.X, 0, ToMe.Z)
    local Look = Vector3.new(KillerLook.X, 0, KillerLook.Z)
    if Flat.Magnitude < 0.01 or Look.Magnitude < 0.01 then return true end
    return Look.Unit:Dot(Flat.Unit) >= (Strict and 0.6 or 0.3)
end

local function WallBetween(FromPosition, ToPosition)
    local Ignore = {}
    if LocalCharacter then table.insert(Ignore, LocalCharacter) end
    if PlayersFolder then table.insert(Ignore, PlayersFolder) end
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.IgnoreWater = true
    Params.FilterDescendantsInstances = Ignore
    local Origin = FromPosition
    for _ = 1, 6 do
        local Direction = ToPosition - Origin
        if Direction.Magnitude < 0.5 then return false end
        local Result = workspace:Raycast(Origin, Direction, Params)
        if not Result then return false end
        local Hit = Result.Instance
        if Hit.CanCollide and Hit.CollisionGroup ~= "Killers" then return true end
        table.insert(Ignore, Hit)
        Params.FilterDescendantsInstances = Ignore
        Origin = Result.Position
    end
    return false
end

local function IsBlockedByWallFrom(FromPos, ToPos, Strict)
    if WallBetween(FromPos, ToPos) then return true end
    if Strict then
        local Side = (ToPos - FromPos):Cross(Vector3.yAxis)
        if Side.Magnitude > 0.01 then
            Side = Side.Unit * 1.5
            if WallBetween(FromPos + Side, ToPos + Side) or WallBetween(FromPos - Side, ToPos - Side) then
                return true
            end
        end
    end
    return false
end

local function PassesChecks(Root, CheckCF)
    if not LocalRoot or not Root then return false end
    local CF = CheckCF or Root.CFrame
    local KillerPos = CF.Position
    if State.VisualCheck and not KillerSeesMeFromPos(KillerPos, CF.LookVector, false) then return false end
    if State.WallCheck and IsBlockedByWallFrom(LocalRoot.Position, KillerPos, false) then return false end
    return true
end

local function DragToward(KillerRoot)
    if not State.HitboxDrag or not State.AutoBlock or not LocalRoot or not KillerRoot then return end
    local Distance = (KillerRoot.Position - LocalRoot.Position).Magnitude
    if Distance > 30 then return end

    local Speed = State.DragSpeed or 14
    local Start = os.clock()
    local Duration = 0.35

    task.spawn(function()
        while os.clock() - Start < Duration and LocalRoot and KillerRoot.Parent and State.AutoBlock do
            local Delta = RunService.PreRender:Wait()
            local Direction = KillerRoot.Position - LocalRoot.Position
            Direction = Vector3.new(Direction.X, 0, Direction.Z)
            if Direction.Magnitude <= 3 then break end

            local Ramp = math.sin(math.pi * (os.clock() - Start) / Duration)
            LocalRoot.CFrame = LocalRoot.CFrame + Direction.Unit * Speed * Ramp * Delta
            LocalRoot.CFrame = CFrame.lookAt(LocalRoot.Position, KillerRoot.Position)
        end
    end)
end

local function DoBlock(KillerRoot)
    if os.clock() - LastBlock < 0.05 then return end
    LastBlock = os.clock()
    
    if State.HitboxDrag and KillerRoot and State.AutoBlock then
        DragToward(KillerRoot)
    end

    local Delay = (State.BlockDelay or 0) / 1000
    if Delay > 0 then
        task.delay(Delay, function()
            if LocalRoot and LocalCharacter and LocalCharacter.Parent then
                FireAbility("Block")
            end
        end)
    else
        FireAbility("Block")
    end
end

local BlockWatchers = {}

local HitboxFolder = Instance.new("Folder")
HitboxFolder.Name = "FluxSakenHitboxes"
HitboxFolder.Parent = workspace

local DebrisService = game:GetService("Debris")
local CustomHitboxSize = Vector3.new(5.2, 6, 5.65)
local CustomHitboxOffset = CFrame.new(0, 0, -3.5)

local function GetLocalQueryHitbox()
    if not LocalCharacter then return nil end
    return LocalCharacter:FindFirstChild("QueryHitbox")
end

local function TriggerBlockWithHitbox(Killer, QueryHitbox)
    if not State.AutoBlock or not LocalRoot then return end
    if not PassesChecks(Killer) then return end
    local LocalQuery = GetLocalQueryHitbox()
    if not LocalQuery then return end

    local Params = OverlapParams.new()
    Params.MaxParts = 1
    Params.BruteForceAllSlow = true
    Params.IncludeInstances = { LocalQuery }
    
    for i = 1, 20 do
        if not State.AutoBlock or not QueryHitbox.Parent then break end
        local Part = Instance.new("Part")
        Part.Name = "KillerDetectHitbox"
        Part.Size = CustomHitboxSize * 2.2
        Part.CFrame = QueryHitbox.CFrame * CustomHitboxOffset
        Part.CanCollide = false
        Part.Anchored = true
        Part.CastShadow = false
        Part.Transparency = 1
        Part.Parent = HitboxFolder
        DebrisService:AddItem(Part, 0.4)
        local Hit = workspace:GetPartBoundsInBox(Part.CFrame, Part.Size, Params)
        if #Hit > 0 then
            DoBlock(QueryHitbox)
            break
        end
        task.wait(0.01)
    end
end

local function WatchKiller(Killer)
    if BlockWatchers[Killer] then return end
    local Humanoid = Killer:FindFirstChildOfClass("Humanoid") or Killer:WaitForChild("Humanoid", 5)
    if not Humanoid then return end
    local QueryHitbox = Killer:FindFirstChild("QueryHitbox") or Killer:WaitForChild("QueryHitbox", 5)
    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    local Connections = {}
    local Hooked = {}

    local function Trigger()
        if QueryHitbox then
            task.spawn(TriggerBlockWithHitbox, Killer, QueryHitbox)
        end
    end

    if Animator then
        table.insert(Connections, Animator.AnimationPlayed:Connect(function(Track)
            if not State.AutoBlock then return end
            if not Track or not Track.Animation then return end
            local AnimId = tostring(Track.Animation.AnimationId or ""):match("%d+")
            if AnimId and AttackAnimations["rbxassetid://" .. AnimId] then
                Trigger()
            end
        end))
    end

    local function HookSound(Sound)
        if Hooked[Sound] or not AttackSounds[Sound.SoundId] then return end
        Hooked[Sound] = true
        table.insert(Connections, Sound.Played:Connect(Trigger))
    end

    table.insert(Connections, Killer.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("Sound") and AttackSounds[Descendant.SoundId] then
            Trigger()
            HookSound(Descendant)
        end
    end))

    table.insert(Connections, Killer.AncestryChanged:Connect(function(_, Parent)
        if not Parent then
            for _, Connection in Connections do Connection:Disconnect() end
            table.clear(Connections)
            BlockWatchers[Killer] = nil
        end
    end))

    for _, Descendant in Killer:GetDescendants() do
        if Descendant:IsA("Sound") then HookSound(Descendant) end
    end

    BlockWatchers[Killer] = function()
        for _, Connection in Connections do Connection:Disconnect() end
        table.clear(Connections)
        BlockWatchers[Killer] = nil
    end
end

local KillerAddedConnection

local function SetAutoBlock(Enabled)
    if Enabled then
        if not KillersFolder then return end
        for _, Killer in KillersFolder:GetChildren() do
            task.spawn(WatchKiller, Killer)
        end
        if not KillerAddedConnection then
            KillerAddedConnection = KillersFolder.ChildAdded:Connect(function(Killer)
                if State.AutoBlock then
                    task.spawn(WatchKiller, Killer)
                end
            end)
        end
    else
        if KillerAddedConnection then
            KillerAddedConnection:Disconnect()
            KillerAddedConnection = nil
        end
        for _, Stop in table.clone(BlockWatchers) do
            pcall(Stop)
        end
    end
end

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if State.AutoBlock and KillersFolder and LocalRoot and (os.clock() - LastBlock > 0.4) then
            for _, Killer in KillersFolder:GetChildren() do
                local Root = Killer:FindFirstChild("HumanoidRootPart")
                local Humanoid = Killer:FindFirstChildOfClass("Humanoid")
                local QueryHitbox = Killer:FindFirstChild("QueryHitbox")
                if Root and Humanoid and Humanoid.Health > 0 and QueryHitbox then
                    local Offset = LocalRoot.Position - Root.Position
                    local Dist = Offset.Magnitude
                    if Dist > 1 and Dist < (State.BlockRange or 15) then
                        local Vel = Root.AssemblyLinearVelocity
                        local ToMe = Offset.Unit
                        if Vel.Magnitude > 8 and Vel.Unit:Dot(ToMe) > 0.5 then
                            if PassesChecks(Killer) then
                                task.spawn(TriggerBlockWithHitbox, Killer, QueryHitbox)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if State.StrictVisualCheck and LocalRoot and KillersFolder then
        local Killer = GetClosestKiller(150)
        if Killer and Killer.Parent then
            local krp = Killer:FindFirstChild("HumanoidRootPart")
            if krp then
                if beamAtt0.Parent ~= LocalRoot then beamAtt0.Parent = LocalRoot end
                if beamAtt1.Parent ~= krp then beamAtt1.Parent = krp end
                
                local Offset = LocalRoot.Position - krp.Position
                local Look = Vector3.new(krp.CFrame.LookVector.X, 0, krp.CFrame.LookVector.Z)
                local ToMe = Vector3.new(Offset.X, 0, Offset.Z)
                
                local IsSeeing = false
                if Look.Magnitude > 0.01 and ToMe.Magnitude > 0.01 then
                    if Look.Unit:Dot(ToMe.Unit) > 0.6 then
                        local Params = RaycastParams.new()
                        Params.FilterType = Enum.RaycastFilterType.Exclude
                        Params.FilterDescendantsInstances = {LocalCharacter, Killer}
                        local Ray = workspace:Raycast(krp.Position, LocalRoot.Position - krp.Position, Params)
                        if not Ray then IsSeeing = true end
                    end
                end
                
                VisualBeam.Color = ColorSequence.new(IsSeeing and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                VisualBeam.Enabled = true
            else
                VisualBeam.Enabled = false
            end
        else
            VisualBeam.Enabled = false
        end
    else
        VisualBeam.Enabled = false
    end
end)

local AimConnection

local function StopAiming()
    if AimConnection then
        AimConnection:Disconnect()
        AimConnection = nil
    end
end

local function GetNearestHeavyRoot()
    if not LocalRoot then return nil end
    local Best
    local BestDistance = math.huge
    for _, Player in Players:GetPlayers() do
        if Player ~= LocalPlayer and Player.Character then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if Humanoid and Root and Humanoid.MaxHealth > 500 then
                local Magnitude = (LocalRoot.Position - Root.Position).Magnitude
                if Magnitude < BestDistance then
                    Best = Root
                    BestDistance = Magnitude
                end
            end
        end
    end
    return Best
end

local function StartAiming()
    StopAiming()
    AimConnection = RunService.Heartbeat:Connect(function()
        if not State.PunchAimbot or not LocalRoot then return end
        local Target = GetNearestHeavyRoot()
        if not Target then return end
        local Direction = Target.Position - LocalRoot.Position
        Direction = Vector3.new(Direction.X, 0, Direction.Z)
        if Direction.Magnitude < 0.01 then return end
        LocalRoot.CFrame = CFrame.new(LocalRoot.Position, LocalRoot.Position + Direction.Unit)
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
        end
    end)
end

local AnimationConnection

local function HookAnimations()
    if AnimationConnection then
        AnimationConnection:Disconnect()
        AnimationConnection = nil
    end
    StopAiming()
    if not LocalHumanoid then return end
    AnimationConnection = LocalHumanoid.AnimationPlayed:Connect(function(Track)
        local Animation = Track.Animation
        if not Animation then return end
        local Id = Animation.AnimationId
        if PunchAnimations[Id] and State.PunchAimbot then
            StartAiming()
            Track.Stopped:Connect(StopAiming)
        end
    end)
end

table.insert(CharacterCallbacks, HookAnimations)

table.insert(CharacterCallbacks, function()
    if not LocalCharacter then return end
    LocalCharacter:GetAttributeChangedSignal("TimesHit"):Connect(function()
        if State.AutoPunch and SpeedMultipliers and SpeedMultipliers:FindFirstChild("GuestBlocking") and LocalHumanoid and (LocalHumanoid:GetAttribute("Overheal") or 0) >= 10 and GetClosestKiller(55) then
            task.wait(0.08)
            FireAbility("Punch")
        end
    end)
end)

local PingGui
local PingToken = 0

local function GetPingColor(Ping)
    if Ping <= 60 then return Color3.fromRGB(60, 220, 80)
    elseif Ping <= 120 then return Color3.fromRGB(255, 220, 50)
    elseif Ping <= 200 then return Color3.fromRGB(255, 150, 40)
    else return Color3.fromRGB(255, 60, 60) end
end

local function SetShowPing(Enabled)
    PingToken += 1
    if PingGui then PingGui:Destroy(); PingGui = nil end
    if not Enabled then return end
    local Token = PingToken
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "PingDisplay"
    Gui.ResetOnSpawn = false
    Gui.Parent = PlayerGui
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 82, 0, 28)
    Box.Position = UDim2.new(0, 6, 0, 6)
    Box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Box.BackgroundTransparency = 0.15
    Box.BorderSizePixel = 0
    Box.Parent = Gui
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Transparency = 0.35
    Stroke.Parent = Box
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.Text = "Ping: 0 ms"
    Label.Parent = Box
    PingGui = Gui
    task.spawn(function()
        local LastPing = nil
        while Token == PingToken and Gui.Parent do
            local Success, Ping = pcall(function() return LocalPlayer:GetNetworkPing() end)
            if Success and typeof(Ping) == "number" and Ping >= 0 then
                Ping = math.round(Ping * 1000)
                if Ping ~= LastPing then
                    LastPing = Ping
                    Label.Text = "Ping: " .. Ping .. " ms"
                    Label.TextColor3 = GetPingColor(Ping)
                end
            end
            task.wait(1)
        end
    end)
end

local SprintingModule
local SprintingHooked = false

local function GetSprinting()
    if SprintingModule then return SprintingModule end
    local Success, Module = pcall(function()
        return require(ReplicatedStorage.Systems.Character.Game.Sprinting)
    end)
    if Success and type(Module) == "table" then SprintingModule = Module end
    return SprintingModule
end

local function SetInfiniteStamina(Enabled)
    local Sprinting = GetSprinting()
    if not Sprinting then
        Notify("Infinite Stamina", "Could not find the sprinting module", 4)
        return
    end
    if not SprintingHooked and typeof(Sprinting.Init) == "function" then
        SprintingHooked = true
        local OldInit = Sprinting.Init
        Sprinting.Init = function(...)
            local Result = OldInit(...)
            if State.InfiniteStamina then Sprinting.StaminaLossDisabled = true end
            return Result
        end
    end
    Sprinting.StaminaLossDisabled = Enabled and true or false
end

local EspColors = {
    Killer = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(60, 255, 100),
    Generator = Color3.fromRGB(0, 255, 255),
    Item = Color3.fromRGB(255, 215, 0),
    Pizza = Color3.fromRGB(255, 170, 0),
    Delivery = Color3.fromRGB(255, 120, 120),
    Zombie = Color3.fromRGB(200, 100, 100),
    Tripwire = Color3.fromRGB(170, 60, 200),
    Mine = Color3.fromRGB(255, 0, 255),
    Graffiti = Color3.fromRGB(255, 255, 255),
    Respawn = Color3.fromRGB(0, 150, 255),
    Bulb = Color3.fromRGB(0, 255, 200),
    Vine = Color3.fromRGB(200, 0, 255)
}

local DummyNames = {
    "PizzaDeliveryRig", "Mafiaso1", "Mafiaso2", "Builderman", "Elliot", "ShedletskyCORRUPT",
    "ChancecORRUPT", "ChanceCORRUPT", "Mafia1", "Mafia2", "Mafia3", "Mafia4", "Mafia5",
    "Mafia6", "Mafia7", "Mafia8", "Mafia9", "GreenGuy", "RedGuy", "BlueGuy", "PurpleGuy",
    "PinkGuy", "YellowGuy", "OrangeGuy", "GreyGuy"
}

local ObjectLists = {
    { "Pizza", "PizzaEsp", "Pizza", "Pizza", "PizzaTracers" },
    { "Delivery", "DeliveryEsp", "Delivery", "Delivery", "DeliveryTracers" },
    { "Zombie", "ZombieEsp", "Zombie", "Zombie", "ZombieTracers" },
    { "Tripwire", "TripwireEsp", "Tripwire", "Tripwire", "TripwireTracers" },
    { "Mine", "MineEsp", "Mine", "Mine", "MineTracers" },
    { "Graffiti", "GraffitiEsp", "Graffiti", "Graffiti" },
    { "Respawn", "RespawnEsp", "Respawn", "Respawn", "RespawnTracers" },
    { "Bulb", "BulbEsp", "Bulb", "GroundBulb" },
    { "Vine", "VineEsp", "Vine", "Vine" }
}

local function GetObjectRoot(Object)
    if Object:IsA("BasePart") then return Object end
    return Object:FindFirstChild("HumanoidRootPart") or Object.PrimaryPart or Object:FindFirstChildWhichIsA("BasePart", true)
end

local EspCache = { Generators = {}, Items = {} }
local EspLastScan = -math.huge
local Tracers = {}

local function AnyEspNeeded()
    return State.KillerEsp or State.SurvivorEsp or State.GeneratorEsp or State.ItemEsp
        or State.KillerTracers or State.SurvivorTracers or State.GeneratorTracers or State.ItemTracers
        or State.PizzaEsp or State.DeliveryEsp or State.ZombieEsp or State.TripwireEsp
        or State.MineEsp or State.GraffitiEsp or State.RespawnEsp or State.BulbEsp or State.VineEsp
        or State.PizzaTracers or State.DeliveryTracers or State.ZombieTracers
        or State.TripwireTracers or State.MineTracers or State.RespawnTracers
        or State.AutoPickup or State.AutoGeneratorMinigame
end

local function SetHighlight(Object, Root, Enabled, Color, Text)
    local Highlight = Object:FindFirstChild("SAB_Highlight")
    local Billboard = Root and Root:FindFirstChild("SAB_Text")
    if Enabled and State.LimitEsp and Root and Root.Parent then
        local Camera = workspace.CurrentCamera
        if Camera and (Camera.CFrame.Position - Root.Position).Magnitude > (State.EspMaxDistance or 10) then
            Enabled = false
        end
    end
    if not Enabled or not Root or not Root.Parent then
        if Highlight then Highlight:Destroy() end
        if Billboard then Billboard:Destroy() end
        return
    end
    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "SAB_Highlight"
        Highlight.Archivable = false
        Highlight.FillTransparency = 0.6
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Adornee = Object
        Highlight.Parent = Object
    end
    Highlight.FillColor = Color
    Highlight.OutlineColor = Color
    if State.EspNames or State.EspHealth or State.KillerSkin or State.SurvivorSkin then
        if not Billboard then
            Billboard = Instance.new("BillboardGui")
            Billboard.Name = "SAB_Text"
            Billboard.Archivable = false
            Billboard.Size = UDim2.new(0, 150, 0, 22)
            Billboard.StudsOffset = Vector3.new(0, 4, 0)
            Billboard.AlwaysOnTop = true
            Billboard.Adornee = Root
            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.fromScale(1, 1)
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextStrokeTransparency = 0
            Label.Parent = Billboard
            Billboard.Parent = Root
        end
        local Label = Billboard:FindFirstChildOfClass("TextLabel")
        local Camera = workspace.CurrentCamera
        local Distance = Camera and math.floor((Camera.CFrame.Position - Root.Position).Magnitude) or 0
        Label.TextColor3 = Color
        Label.Text = Text .. " [" .. Distance .. "]"
    elseif Billboard then
        Billboard:Destroy()
    end
end

local function RemoveTracer(Model)
    local Data = Tracers[Model]
    if Data then
        Data.Beam:Destroy()
        Data.Attachment:Destroy()
        Tracers[Model] = nil
    end
end

local function SetTracer(Model, Root, Enabled, Color)
    if not Enabled or not Root or not Root.Parent or not LocalRoot then
        RemoveTracer(Model)
        return
    end
    local Origin = LocalRoot:FindFirstChild("SAB_TracerOrigin")
    if not Origin then
        Origin = Instance.new("Attachment")
        Origin.Name = "SAB_TracerOrigin"
        Origin.Parent = LocalRoot
    end
    local Data = Tracers[Model]
    if Data and (Data.Beam.Attachment0 ~= Origin or not Data.Attachment.Parent) then
        RemoveTracer(Model)
        Data = nil
    end
    if not Data then
        local EndAt = Instance.new("Attachment")
        EndAt.Name = "SAB_TracerEnd"
        EndAt.Parent = Root
        local Beam = Instance.new("Beam")
        Beam.Name = "SAB_Tracer"
        Beam.Attachment0 = Origin
        Beam.Attachment1 = EndAt
        Beam.Width0 = 0.15
        Beam.Width1 = 0.15
        Beam.FaceCamera = true
        Beam.LightEmission = 1
        Beam.Segments = 1
        Beam.Color = ColorSequence.new(Color)
        Beam.Parent = Root
        Tracers[Model] = { Beam = Beam, Attachment = EndAt }
    else
        Data.Beam.Color = ColorSequence.new(Color)
    end
end

local function EspScan()
    if not InGame then return end
    local Cache = {
        Generators = {}, Items = {}, Pizza = {}, Delivery = {}, Zombie = {},
        Tripwire = {}, Mine = {}, Graffiti = {}, Respawn = {}, Bulb = {}, Vine = {}
    }
    for _, Object in InGame:GetDescendants() do
        local Name = Object.Name
        local Lower = Name:lower()
        if Object:IsA("Tool") then
            local Parent = Object.Parent
            if not (Parent and Parent:IsA("Model") and Parent:FindFirstChildOfClass("Humanoid")) then
                table.insert(Cache.Items, Object)
            end
        elseif Object:IsA("BasePart") and Name == "Pizza" then
            table.insert(Cache.Pizza, Object)
        elseif Object:IsA("BasePart") and Name == "GraffitiCL" then
            table.insert(Cache.Graffiti, Object)
        elseif Lower:find("respawnlocation") and (Object:IsA("Model") or Object:IsA("BasePart")) then
            table.insert(Cache.Respawn, Object)
        elseif Object:IsA("Model") then
            if Name == "Generator" and Object:FindFirstChild("Main") then
                table.insert(Cache.Generators, Object)
            elseif table.find(DummyNames, Name) and Object:FindFirstChild("HumanoidRootPart") then
                table.insert(Cache.Delivery, Object)
            elseif Name == "1x1x1x1Zombie" then
                table.insert(Cache.Zombie, Object)
            elseif Name:match("TaphTripwire$") then
                table.insert(Cache.Tripwire, Object)
            elseif Name == "SubspaceTripmine" then
                table.insert(Cache.Mine, Object)
            elseif Lower == "groundbulbmodel" then
                table.insert(Cache.Bulb, Object)
            elseif Lower == "vinemodel" then
                table.insert(Cache.Vine, Object)
            end
        end
    end
    EspCache = Cache
end

local function EspPlayers(Folder, EspKey, ColorKey, TracerKey)
    if not Folder then return end
    local espOn = State[EspKey]
    local tracerOn = TracerKey and State[TracerKey]
    for _, Model in Folder:GetChildren() do
        local hasExisting = Model:FindFirstChild("SAB_Highlight") or (TracerKey and Tracers[Model])
        if espOn or tracerOn or hasExisting then
            local Player = Players:GetPlayerFromCharacter(Model)
            local Root = Model:FindFirstChild("HumanoidRootPart")
            local Humanoid = Model:FindFirstChildOfClass("Humanoid")
            local Valid = Player ~= nil and Player ~= LocalPlayer and Root ~= nil and Humanoid ~= nil and Humanoid.Health > 0
            local Label = Player and Player.Name or Model.Name
            if State.EspHealth and Humanoid then
                Label = Label .. " | HP " .. math.floor(Humanoid.Health) .. "/" .. math.floor(Humanoid.MaxHealth)
            end
            if (EspKey == "KillerEsp" and State.KillerSkin) or (EspKey == "SurvivorEsp" and State.SurvivorSkin) then
                local Skin = Model:GetAttribute("SkinNameDisplay")
                if Skin and Skin ~= "" then Label = Label .. " | " .. Skin end
            end
            SetHighlight(Model, Root, Valid and espOn, EspColors[ColorKey], Label)
            if TracerKey then
                SetTracer(Model, Root, Valid and tracerOn, EspColors[ColorKey])
            end
        end
    end
end

local function EspStep()
    EspPlayers(KillersFolder, "KillerEsp", "Killer", "KillerTracers")
    EspPlayers(SurvivorsFolder, "SurvivorEsp", "Survivor", "SurvivorTracers")
    for Model in Tracers do
        if not Model.Parent then RemoveTracer(Model) end
    end
    if AnyEspNeeded() and os.clock() - EspLastScan > 3 then
        EspLastScan = os.clock()
        EspScan()
    end
    if State.GeneratorEsp or State.GeneratorTracers then
        for _, Object in EspCache.Generators do
            if Object.Parent then
                local Bar = Object:FindFirstChild("BarUI", true)
                Bar = Bar and Bar:FindFirstChild("Bar")
                local Progress = Object:FindFirstChild("Progress")
                local Finished = (Bar and Bar.Size.X.Scale >= 1) or (Progress and Progress.Value >= 100)
                SetHighlight(Object, Object:FindFirstChild("Main"), State.GeneratorEsp and not Finished, EspColors.Generator, "Generator")
                SetTracer(Object, Object:FindFirstChild("Main"), State.GeneratorEsp and State.GeneratorTracers and not Finished, EspColors.Generator)
            end
        end
    end
    if State.ItemEsp or State.ItemTracers then
        for _, Tool in EspCache.Items do
            if Tool.Parent then
                local Part = Tool:FindFirstChildWhichIsA("BasePart")
                local Prompt = Tool:FindFirstChildWhichIsA("ProximityPrompt", true)
                SetHighlight(Tool, Part, State.ItemEsp, EspColors.Item, Prompt and Prompt.ActionText ~= "" and Prompt.ActionText or Tool.Name)
                SetTracer(Tool, Part, State.ItemEsp and State.ItemTracers, EspColors.Item)
            end
        end
    end
    for _, Data in ObjectLists do
        if State[Data[2]] or (Data[5] and State[Data[5]]) then
            for _, Object in EspCache[Data[1]] do
                if Object.Parent then
                    local ObjectRoot = GetObjectRoot(Object)
                    SetHighlight(Object, ObjectRoot, State[Data[2]], EspColors[Data[3]], Data[4])
                    if Data[5] then
                        SetTracer(Object, ObjectRoot, State[Data[2]] and State[Data[5]], EspColors[Data[3]])
                    end
                end
            end
        end
    end
end

pcall(EspScan)
EspLastScan = os.clock()

task.spawn(function()
    while task.wait(0.3) do
        pcall(EspStep)
    end
end)

local function CheckSlowness(ValueInstance)
    if not State.AntiSlowness or not ValueInstance or not ValueInstance:IsA("NumberValue") then return end
    local Name = ValueInstance.Name
    if Name == "Sprinting" or Name:lower() == "emoting" then return end
    if Name == "DirectionalMovement" or Name == "FixingGenerator" or Name:upper() == "ENRAGED" then
        if ValueInstance.Value < 1 then ValueInstance.Value = 1 end
        ValueInstance:GetPropertyChangedSignal("Value"):Connect(function()
            if ValueInstance.Value < 1 then ValueInstance.Value = 1 end
        end)
    elseif ValueInstance.Value > 0.03 and ValueInstance.Value < 1 then
        ValueInstance:Destroy()
    else
        ValueInstance:GetPropertyChangedSignal("Value"):Connect(function()
            if ValueInstance.Value > 0.03 and ValueInstance.Value < 1 then ValueInstance:Destroy() end
        end)
    end
end

local function SetAntiSlowness(Enabled)
    if Enabled and SpeedMultipliers then
        for _, Child in SpeedMultipliers:GetChildren() do CheckSlowness(Child) end
    end
end

table.insert(CharacterCallbacks, function()
    if SpeedMultipliers then
        SpeedMultipliers.ChildAdded:Connect(CheckSlowness)
        SetAntiSlowness(State.AntiSlowness)
    end
end)

local function ApplyJumping()
    if not LocalHumanoid then return end
    if State.EnableJumping then
        if LocalHumanoid:GetAttribute("SAB_JumpPower") == nil then
            LocalHumanoid:SetAttribute("SAB_JumpPower", LocalHumanoid.JumpPower)
        end
        LocalHumanoid.UseJumpPower = true
        LocalHumanoid.JumpPower = 47
    elseif LocalHumanoid:GetAttribute("SAB_JumpPower") ~= nil then
        LocalHumanoid.JumpPower = LocalHumanoid:GetAttribute("SAB_JumpPower")
        LocalHumanoid:SetAttribute("SAB_JumpPower", nil)
    end
end

table.insert(CharacterCallbacks, function()
    task.wait(0.25)
    ApplyJumping()
end)

local function ApplyInjury()
    local TempUI = PlayerGui:FindFirstChild("TemporaryUI")
    if TempUI then
        for _, Object in TempUI:GetDescendants() do
            if Object.Name == "redFlash" or Object.Name == "injuredVignette" then
                Object.Visible = not State.HideInjury
            end
        end
    end
    local Desaturation = Lighting:FindFirstChild("HealthDesaturation")
    if Desaturation then Desaturation.Enabled = not State.HideInjury end
end

local function ApplyBlindness()
    local Blur = Lighting:FindFirstChild("BlindnessBlur")
    if Blur and Blur:IsA("BlurEffect") then Blur.Enabled = not State.DisableBlindness end
end

Lighting.ChildAdded:Connect(function(Child)
    if Child.Name == "HealthDesaturation" and State.HideInjury then
        Child.Enabled = false
    elseif Child.Name == "BlindnessBlur" and Child:IsA("BlurEffect") and State.DisableBlindness then
        Child.Enabled = false
    end
end)

local DefaultZoom = LocalPlayer.CameraMaxZoomDistance
local DefaultOcclusion = LocalPlayer.DevCameraOcclusionMode

local function SetFreeZoom(Enabled)
    LocalPlayer.CameraMaxZoomDistance = Enabled and math.huge or DefaultZoom
end

local function SetCameraNoclip(Enabled)
    LocalPlayer.DevCameraOcclusionMode = Enabled and Enum.DevCameraOcclusionMode.Invisicam or DefaultOcclusion
end

local LightingSaved
local FullbrightToken = 0

local function SetFullbright(Enabled)
    FullbrightToken += 1
    if Enabled then
        if not LightingSaved then
            LightingSaved = {
                Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                GlobalShadows = Lighting.GlobalShadows
            }
        end
        local Token = FullbrightToken
        task.spawn(function()
            while Token == FullbrightToken do
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                Lighting.GlobalShadows = false
                task.wait(0.5)
            end
        end)
    elseif LightingSaved then
        Lighting.Brightness = LightingSaved.Brightness
        Lighting.Ambient = LightingSaved.Ambient
        Lighting.OutdoorAmbient = LightingSaved.OutdoorAmbient
        Lighting.GlobalShadows = LightingSaved.GlobalShadows
        LightingSaved = nil
    end
end

local RagdollConnection

local function SetDeleteRagdolls(Enabled)
    if RagdollConnection then
        RagdollConnection:Disconnect()
        RagdollConnection = nil
    end
    local Folder = workspace:FindFirstChild("Ragdolls")
    if not Enabled or not Folder then return end
    Folder:ClearAllChildren()
    RagdollConnection = Folder.ChildAdded:Connect(function(Child)
        task.defer(function() Child:Destroy() end)
    end)
end

local function FirePrompt(Prompt)
    if typeof(fireproximityprompt) == "function" then
        fireproximityprompt(Prompt)
    else
        Prompt:InputHoldBegin()
        Prompt:InputHoldEnd()
    end
end

local SpeedToken = 0

local function SetSpeedBoost(Enabled)
    SpeedToken += 1
    if not Enabled then return end
    local Token = SpeedToken
    task.spawn(function()
        while Token == SpeedToken do
            local Delta = RunService.Heartbeat:Wait()
            if LocalCharacter and LocalHumanoid and LocalHumanoid.MoveDirection.Magnitude > 0 then
                LocalCharacter:TranslateBy(LocalHumanoid.MoveDirection * (State.SpeedValue or 1) * Delta)
            end
        end
    end)
end

local FlightConnection

local function StopFlight()
    if FlightConnection then
        FlightConnection:Disconnect()
        FlightConnection = nil
    end
    if LocalHumanoid then LocalHumanoid.PlatformStand = false end
    local Head = LocalCharacter and LocalCharacter:FindFirstChild("Head")
    if Head then Head.Anchored = false end
end

local function StartFlight()
    StopFlight()
    local Character = LocalCharacter
    local Humanoid = LocalHumanoid
    local Head = Character and Character:FindFirstChild("Head")
    if not Humanoid or not Head then return end
    Humanoid.PlatformStand = true
    Head.Anchored = true
    FlightConnection = RunService.Heartbeat:Connect(function(Delta)
        if not Character.Parent then StopFlight(); return end
        local Camera = workspace.CurrentCamera
        if not Camera then return end
        local Move = Humanoid.MoveDirection * ((State.FlightSpeed or 1) * Delta)
        local HeadCF = Head.CFrame
        local CamCF = Camera.CFrame
        local Offset = HeadCF:ToObjectSpace(CamCF).Position
        CamCF = CamCF * CFrame.new(-Offset.X, -Offset.Y, -Offset.Z + 1)
        local CamPos = CamCF.Position
        local HeadPos = HeadCF.Position
        local Moved = CFrame.new(CamPos, Vector3.new(HeadPos.X, CamPos.Y, HeadPos.Z)):VectorToObjectSpace(Move)
        Head.CFrame = CFrame.new(HeadPos) * (CamCF - CamPos) * CFrame.new(Moved)
    end)
end

local function SetFlight(Enabled)
    if Enabled then StartFlight() else StopFlight() end
end

table.insert(CharacterCallbacks, function()
    if State.Flight then
        task.wait(0.5)
        StartFlight()
    end
end)

local function FakeNoliStep()
    if not State.DeleteFakeNoli or not KillersFolder then return end
    for _, Model in KillersFolder:GetChildren() do
        if Model:IsA("Model") and Model:GetAttribute("IsFakeNoli") == true then
            Model:Destroy()
        end
    end
end

if InGame then
    InGame.ChildAdded:Connect(function(Child)
        if Child:IsA("Tool") then
            Child:SetAttribute("JustDropped", true)
            task.delay(1.5, function()
                if Child then Child:SetAttribute("JustDropped", nil) end
            end)
        end
    end)
end

local function AutoPickupStep()
    if not State.AutoPickup or not LocalRoot or not LocalCharacter then return end
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, Tool in EspCache.Items do
        local Parent = Tool.Parent
        if Parent and not (Parent:IsA("Model") and Parent:FindFirstChildOfClass("Humanoid")) and not Tool:GetAttribute("JustDropped") and not LocalCharacter:FindFirstChild(Tool.Name) and not (Backpack and Backpack:FindFirstChild(Tool.Name)) then
            local Part = Tool:FindFirstChildWhichIsA("BasePart")
            local Prompt = Tool:FindFirstChildWhichIsA("ProximityPrompt", true)
            if Part and Part.Parent and Prompt and (Part.Position - LocalRoot.Position).Magnitude <= 4.5 then
                FirePrompt(Prompt)
            end
        end
    end
end

local function TPToItem(ItemName)
    if not LocalRoot or not LocalCharacter then return end
    local TargetItem = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and obj.Name:lower():find(ItemName:lower()) then
            TargetItem = obj
            break
        end
    end

    if TargetItem and TargetItem.Parent then
        local OldCFrame = LocalRoot.CFrame
        local OldAutoPickup = State.AutoPickup
        
        State.AutoPickup = true
        LocalRoot.CFrame = TargetItem.CFrame * CFrame.new(0, 1.5, 0)
        task.wait(0.3)
        if LocalRoot and LocalCharacter and LocalCharacter.Parent then
            LocalRoot.CFrame = OldCFrame
        end
        task.wait(0.5)
        
        if not OldAutoPickup then
            State.AutoPickup = false
        end
    else
        Notify("Items", "Could not find " .. ItemName .. " nearby", 3)
    end
end

local LastEscape = 0

local function AutoEscapeStep()
    if not State.AutoEscape or not Remote or not KillersFolder or os.clock() - LastEscape < (State.EscapeCooldown or 0.5) then return end
    local TempUI = PlayerGui:FindFirstChild("TemporaryUI")
    local QTE = TempUI and TempUI:FindFirstChild("QTE")
    if QTE and QTE.Visible then
        LastEscape = os.clock()
        for _, Killer in KillersFolder:GetChildren() do
            if Killer.Name:lower() == "nosferatu" then
                local Player = Players:GetPlayerFromCharacter(Killer)
                if Player then
                    Remote:FireServer(Player.Name .. "NosHookQTE", { true })
                end
            end
        end
    end
end

local CurrentQTEAzure
local AzureHooked = false

local function SetAutoDisarm(Enabled)
    if Enabled and typeof(CurrentQTEAzure) == "table" and typeof(CurrentQTEAzure.AddProgress) == "function" then
        CurrentQTEAzure:AddProgress(100)
        CurrentQTEAzure = nil
    end
    if AzureHooked or not Enabled or typeof(hookfunction) ~= "function" then return end
    pcall(function()
        local Killers = ReplicatedStorage.Assets.Killers
        local Azure = Killers:FindFirstChild("Azure") or Killers:FindFirstChild("!Azure")
        local QTEModule = Azure and Azure:FindFirstChild("cl_ConstructQTE", true)
        if not QTEModule then return end
        local Required = require(QTEModule)
        if typeof(Required) ~= "table" or typeof(Required.new) ~= "function" then return end
        local Original
        Original = hookfunction(Required.new, function(...)
            local Result = Original(...)
            task.delay(0.05, function()
                if typeof(Result) == "table" and typeof(Result.AddProgress) == "function" then
                    if State.AutoDisarm then
                        Result:AddProgress(100)
                    else
                        CurrentQTEAzure = Result
                    end
                end
            end)
            return Result
        end)
        AzureHooked = typeof(Original) == "function"
    end)
end

local function ApplyInGameObjects()
    if not InGame then return end
    for _, Object in InGame:GetChildren() do
        local Lower = Object.Name:lower()
        if Object:IsA("Folder") and Object.Name:find("JohnDoeTrail") then
            for _, Part in Object:GetChildren() do
                if Part:IsA("BasePart") then Part.CanTouch = not State.DisableTrails end
            end
        elseif Object:IsA("Folder") and (Lower:find("shadows") or Lower:find("footprint")) then
            for _, Part in Object:GetChildren() do
                if Part:IsA("BasePart") then Part.CanTouch = not State.DisableFootprints end
            end
        elseif Object.Name == "SpikeCollision" then
            Object.Size = State.SmallSpikes and Vector3.new(11, 3.5, 3.5) or Vector3.new(11, 5, 5)
            Object.Shape = State.SmallSpikes and Enum.PartType.Cylinder or Enum.PartType.Block
        end
    end
end

local function HandleNoliNPC()
    if not KillersFolder or not InGame then return end
    if State.DisableNoliNPC then
        for _, Model in KillersFolder:GetChildren() do
            if Model.Name:lower() == "noli" and not Players:GetPlayerFromCharacter(Model) then
                Model.Parent = Lighting
                pcall(function()
                    Model:PivotTo(Model:GetPivot() * CFrame.new(0, -100, 0))
                end)
            end
        end
        local Themes = workspace:FindFirstChild("Themes")
        if Themes then
            for _, Sound in Themes:GetChildren() do
                if Sound.Name:find("FakeLayer") and Sound:IsA("Sound") then Sound:Destroy() end
            end
        end
    else
        for _, Model in Lighting:GetChildren() do
            if Model.Name:lower() == "noli" then
                Model.Parent = InGame
                pcall(function()
                    Model:PivotTo(Model:GetPivot() * CFrame.new(0, 100, 0))
                end)
            end
        end
    end
end

local function Handle007n7NPC()
    if not InGame then return end
    if State.Disable007n7NPC then
        for _, Model in InGame:GetChildren() do
            if Model.Name:lower() == "007n7" and not Players:GetPlayerFromCharacter(Model) then
                Model.Parent = Lighting
                local Root = Model:FindFirstChild("HumanoidRootPart")
                if Root then
                    Root.ChildAdded:Connect(function(Child)
                        if Child:IsA("Sound") and State.Disable007n7NPC then Child:Destroy() end
                    end)
                end
            end
        end
    else
        for _, Model in Lighting:GetChildren() do
            if Model.Name:lower() == "007n7" then Model.Parent = InGame end
        end
    end
end

if KillersFolder then
    KillersFolder.ChildAdded:Connect(function()
        task.wait(0.5)
        HandleNoliNPC()
    end)
end

if InGame then
    InGame.ChildAdded:Connect(function()
        task.wait(0.1)
        Handle007n7NPC()
    end)
end

local PrivacyKeys = { "HideKillerWins", "HidePlaytime", "HideSurvivorWins" }
local PrivacyOriginals = {}

local function ApplyHiddenStats(Player)
    local Data = Player:FindFirstChild("PlayerData")
    local Settings = Data and Data:FindFirstChild("Settings")
    local Privacy = Settings and Settings:FindFirstChild("Privacy")
    if not Privacy then return end
    local Originals = PrivacyOriginals[Player.UserId]
    if not Originals then
        Originals = {}
        PrivacyOriginals[Player.UserId] = Originals
    end
    for _, Key in PrivacyKeys do
        local Setting = Privacy:FindFirstChild(Key)
        if Setting then
            if State.AntiHiddenStats then
                if Originals[Key] == nil then Originals[Key] = Setting.Value end
                Setting.Value = false
            elseif Originals[Key] ~= nil then
                Setting.Value = Originals[Key]
                Originals[Key] = nil
            end
        end
    end
end

local function SetAntiHiddenStats()
    for _, Player in Players:GetPlayers() do
        ApplyHiddenStats(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    task.delay(2, function()
        if State.AntiHiddenStats then ApplyHiddenStats(Player) end
    end)
end)

local function SetKillerWalls(Enabled)
    for _, Object in workspace:GetDescendants() do
        if Object.Name == "KillerDoors" then
            for _, Wall in Object:GetChildren() do
                if Wall:IsA("BasePart") then Wall.CanCollide = not Enabled end
            end
        end
    end
end

local ChatToken = 0

local function SetShowChat(Enabled)
    ChatToken += 1
    if not Enabled then return end
    local Token = ChatToken
    task.spawn(function()
        while Token == ChatToken do
            local Config = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
            if Config then Config.Enabled = true end
            task.wait(0.25)
        end
    end)
end

local DefaultFov
local FovToken = 0

local function SetFov(Enabled)
    FovToken += 1
    local Camera = workspace.CurrentCamera
    if Enabled then
        if Camera and not DefaultFov then DefaultFov = Camera.FieldOfView end
        local Token = FovToken
        task.spawn(function()
            while Token == FovToken do
                local Current = workspace.CurrentCamera
                if Current then Current.FieldOfView = State.FovValue or 70 end
                RunService.RenderStepped:Wait()
            end
        end)
    elseif Camera and DefaultFov then
        Camera.FieldOfView = DefaultFov
        DefaultFov = nil
    end
end

local function RejoinServer()
    Notify("Rejoin", "Rejoining...", 3)
    if workspace:GetAttribute("ServerType") == "VIP" then
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
end

task.spawn(function()
    while task.wait(0.25) do
        if State.AutoPickup then pcall(AutoPickupStep) end
        if State.AutoEscape then pcall(AutoEscapeStep) end
        if State.DeleteFakeNoli then pcall(FakeNoliStep) end
        if State.DisableTrails or State.DisableFootprints or State.SmallSpikes then
            pcall(ApplyInGameObjects)
        end
    end
end)

local Feature = {}

do
    local ChanceShootConnection
    local ChanceCoinToken = 0

    local function SetupChanceShoot(Button)
        if ChanceShootConnection then ChanceShootConnection:Disconnect() end
        ChanceShootConnection = Button.Activated:Connect(function()
            if not State.ChanceAim or not LocalRoot or not LocalHumanoid or not KillersFolder then return end
            local Target
            for _, Model in KillersFolder:GetChildren() do
                if Model:IsA("Model") then Target = Model; break end
            end
            local TargetRoot = Target and (Target:FindFirstChild("HumanoidRootPart") or Target.PrimaryPart)
            if not TargetRoot then return end
            local Humanoid = LocalHumanoid
            local Root = LocalRoot
            local AutoRotate = Humanoid.AutoRotate
            local Start = os.clock()
            local Connection
            Humanoid.AutoRotate = false
            Connection = RunService.RenderStepped:Connect(function()
                if os.clock() - Start >= 2 or not Root.Parent or not TargetRoot.Parent then
                    Humanoid.AutoRotate = AutoRotate
                    Connection:Disconnect()
                    return
                end
                local Position = TargetRoot.Position + TargetRoot.CFrame.LookVector * (tonumber(State.ChancePrediction) or 4)
                Root.CFrame = CFrame.lookAt(Root.Position, Vector3.new(Position.X, Root.Position.Y, Position.Z))
            end)
        end)
    end

    local function HookChanceShoot()
        local Button = PlayerGui:FindFirstChild("Shoot", true)
        if Button and Button:IsA("ImageButton") then SetupChanceShoot(Button) end
    end

    PlayerGui.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("ImageButton") and Descendant.Name == "Shoot" then
            SetupChanceShoot(Descendant)
        end
    end)

    task.spawn(HookChanceShoot)

    table.insert(CharacterCallbacks, function()
        task.wait(1)
        HookChanceShoot()
    end)

    Feature.SetChanceCoinFlip = function(Enabled)
        ChanceCoinToken += 1
        if not Enabled then return end
        local Token = ChanceCoinToken
        task.spawn(function()
            while Token == ChanceCoinToken do
                task.wait(0.1)
                local MainUI = PlayerGui:FindFirstChild("MainUI")
                local Container = MainUI and MainUI:FindFirstChild("AbilityContainer")
                local Reroll = Container and Container:FindFirstChild("Reroll")
                local Charges = Reroll and Reroll:FindFirstChild("Charges")
                if LocalRoot and KillersFolder and Remote and Charges and Charges:IsA("TextLabel") and Charges.Text ~= "3" then
                    local Near = false
                    for _, Killer in KillersFolder:GetChildren() do
                        local Root = Killer:FindFirstChild("HumanoidRootPart")
                        if Root and (LocalRoot.Position - Root.Position).Magnitude <= 50 then
                            Near = true
                            break
                        end
                    end
                    if not Near then
                        Remote:FireServer("UseActorAbility", { "CoinFlip" })
                    end
                end
            end
        end)
    end
end

do
    local ShadowsToken = 0
    local ShadowsSaved
    local FogToken = 0
    local FogSaved

    Feature.SetNoShadows = function(Enabled)
        ShadowsToken += 1
        if Enabled then
            if ShadowsSaved == nil then ShadowsSaved = Lighting.GlobalShadows end
            local Token = ShadowsToken
            task.spawn(function()
                while Token == ShadowsToken do
                    Lighting.GlobalShadows = false
                    task.wait(0.5)
                end
            end)
        elseif ShadowsSaved ~= nil then
            Lighting.GlobalShadows = ShadowsSaved
            ShadowsSaved = nil
        end
    end

    Feature.SetNoFog = function(Enabled)
        FogToken += 1
        if Enabled then
            if not FogSaved then
                local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                FogSaved = { Start = Lighting.FogStart, Finish = Lighting.FogEnd, Density = Atmosphere and Atmosphere.Density }
            end
            local Token = FogToken
            task.spawn(function()
                while Token == FogToken do
                    Lighting.FogStart = 1000000
                    Lighting.FogEnd = 1000000
                    local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                    if Atmosphere then Atmosphere.Density = 0 end
                    task.wait(0.5)
                end
            end)
        elseif FogSaved then
            Lighting.FogStart = FogSaved.Start
            Lighting.FogEnd = FogSaved.Finish
            local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if Atmosphere and FogSaved.Density then Atmosphere.Density = FogSaved.Density end
            FogSaved = nil
        end
    end
end

do
    local Originals = {}
    local Fields = {
        { "ModifyMaxStamina", "MaxStamina", "MaxStaminaValue" },
        { "ModifyStaminaGain", "StaminaGain", "StaminaGainValue" },
        { "ModifyStaminaLoss", "StaminaLoss", "StaminaLossValue" },
        { "ModifySprintSpeed", "SprintSpeed", "SprintSpeedValue" }
    }

    Feature.StaminaToggle = function(Field)
        return function(Enabled)
            local Module = GetSprinting()
            if not Module then return end
            if Enabled then
                if Originals[Field] == nil then Originals[Field] = Module[Field] end
            elseif Originals[Field] ~= nil then
                pcall(function() Module[Field] = Originals[Field] end)
                Originals[Field] = nil
            end
        end
    end

    task.spawn(function()
        while task.wait(0.5) do
            local Module = GetSprinting()
            if Module then
                for _, Data in Fields do
                    if State[Data[1]] and type(State[Data[3]]) == "number" then
                        pcall(function() Module[Data[2]] = State[Data[3]] end)
                    end
                end
            end
        end
    end)
end

do
    local DashTurnConnection
    local QteEnabled = false
    local OriginalHitZone
    local HookSlot

    Feature.SetDashTurn = function(Enabled)
        if DashTurnConnection then
            DashTurnConnection:Disconnect()
            DashTurnConnection = nil
        end
        if not Enabled then return end
        DashTurnConnection = RunService.RenderStepped:Connect(function(Delta)
            local Character = LocalCharacter
            local Root = LocalRoot
            if not Character or not Root or Character.Name ~= "c00lkidd" or Character:GetAttribute("FootstepsMuted") ~= true then return end
            local Direction = LocalHumanoid and LocalHumanoid.MoveDirection or Vector3.zero
            if Direction.Magnitude < 0.01 then
                local Camera = workspace.CurrentCamera
                if not Camera then return end
                Direction = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
            end
            if Direction.Magnitude < 0.01 then return end
            Direction = Direction.Unit
            local Velocity = Root:FindFirstChildWhichIsA("LinearVelocity")
            if Velocity then Velocity.LineDirection = Direction end
            local TargetRotation = CFrame.new(Root.Position, Root.Position + Direction).Rotation
            Root.CFrame = CFrame.new(Root.Position) * Root.CFrame.Rotation:Lerp(TargetRotation, math.min(Delta * 16, 1))
        end)
    end

    local function BreakFreeStep()
        if not State.AutoBreakFree or not Remote or not KillersFolder then return end
        local TempUI = PlayerGui:FindFirstChild("TemporaryUI")
        if not (TempUI and TempUI:FindFirstChild("QTE")) then return end
        for _, Killer in KillersFolder:GetChildren() do
            if Killer:IsA("Model") and Killer.Name == "Nosferatu" then
                local Username = Killer:GetAttribute("Username")
                if Username and Username ~= LocalPlayer.Name then
                    Remote:FireServer(Username .. "NosHookQTE", { buffer.fromstring("\x01\x01") })
                    break
                end
            end
        end
    end

    local function PullRopeStep()
        if not State.AutoPullRope or not Remote or not KillersFolder or not LocalHumanoid then return end
        local IsNosferatu = false
        for _, Killer in KillersFolder:GetChildren() do
            if Killer:IsA("Model") and Killer.Name == "Nosferatu" and Killer:GetAttribute("Username") == LocalPlayer.Name then
                IsNosferatu = true
                break
            end
        end
        if not IsNosferatu then return end
        for _, Track in LocalHumanoid:GetPlayingAnimationTracks() do
            local AnimationId = Track.Animation and Track.Animation.AnimationId
            if AnimationId and AnimationId:match("%d+") == "113403615979705" then
                Remote:FireServer(LocalPlayer.Name .. "NosHookQTE", { buffer.fromstring("\x01\x01") })
                break
            end
        end
    end

    task.spawn(function()
        while task.wait(0.1) do
            pcall(BreakFreeStep)
            pcall(PullRopeStep)
        end
    end)

    local function GetQteModule()
        local Assets = ReplicatedStorage:FindFirstChild("Assets")
        local Killers = Assets and Assets:FindFirstChild("Killers")
        local Azure = Killers and Killers:FindFirstChild("Azure")
        local Config = Azure and Azure:FindFirstChild("Config")
        local Workaround = Config and Config:FindFirstChild("cl_WorkaroundModules")
        return Workaround and Workaround:FindFirstChild("cl_ConstructQTE")
    end

    Feature.SetAzureQte = function(Enabled)
        if Enabled then
            if QteEnabled then return end
            if typeof(debug.getupvalues) ~= "function" or typeof(debug.setupvalue) ~= "function" then
                Notify("Auto Azure QTE", "Your executor does not support this", 4)
                return
            end
            QteEnabled = true
            local Module = GetQteModule()
            local Loaded, Behavior = pcall(function() return Module and require(Module) end)
            if not Loaded or type(Behavior) ~= "table" or not Behavior.new then
                QteEnabled = false
                Notify("Auto Azure QTE", "QTE module not found", 4)
                return
            end
            local function PickZone(_, _, Completed)
                if type(Completed) == "table" then
                    for Index = 1, 3 do
                        if not Completed[Index] then return Index end
                    end
                end
                return 1
            end
            for Slot, Value in debug.getupvalues(Behavior.new) do
                if type(Value) == "function" and debug.info(Value, "a") == 3 then
                    OriginalHitZone = Value
                    HookSlot = Slot
                    debug.setupvalue(Behavior.new, Slot, PickZone)
                    Notify("Auto Azure QTE", "Hooked", 3)
                    return
                end
            end
        else
            QteEnabled = false
            if HookSlot and OriginalHitZone then
                local Module = GetQteModule()
                local Loaded, Behavior = pcall(function() return Module and require(Module) end)
                if Loaded and type(Behavior) == "table" and Behavior.new then
                    pcall(debug.setupvalue, Behavior.new, HookSlot, OriginalHitZone)
                end
                HookSlot = nil
                OriginalHitZone = nil
            end
        end
    end
end

do
    local ConfigVersion = "30"

    local B64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    local B64Map = {}
    for i = 1, #B64Chars do B64Map[B64Chars:sub(i,i)] = i - 1 end

    local function ToBase64(Str)
        local Bytes = { string.byte(Str, 1, -1) }
        local Result = {}
        local Pad = (3 - (#Bytes % 3)) % 3
        for _ = 1, Pad do table.insert(Bytes, 0) end
        for i = 1, #Bytes, 3 do
            local b1, b2, b3 = Bytes[i], Bytes[i+1], Bytes[i+2]
            local n = b1 * 65536 + b2 * 256 + b3
            local c1 = math.floor(n / 262144) % 64
            local c2 = math.floor(n / 4096) % 64
            local c3 = math.floor(n / 64) % 64
            local c4 = n % 64
            table.insert(Result, B64Chars:sub(c1+1, c1+1))
            table.insert(Result, B64Chars:sub(c2+1, c2+1))
            table.insert(Result, B64Chars:sub(c3+1, c3+1))
            table.insert(Result, B64Chars:sub(c4+1, c4+1))
        end
        return table.concat(Result), Pad
    end

    local function FromBase64(Str, Pad)
        local Result = {}
        for i = 1, #Str, 4 do
            local c1 = B64Map[Str:sub(i, i)] or 0
            local c2 = B64Map[Str:sub(i+1, i+1)] or 0
            local c3 = B64Map[Str:sub(i+2, i+2)] or 0
            local c4 = B64Map[Str:sub(i+3, i+3)] or 0
            local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
            table.insert(Result, string.char(math.floor(n / 65536) % 256))
            table.insert(Result, string.char(math.floor(n / 256) % 256))
            table.insert(Result, string.char(n % 256))
        end
        for _ = 1, Pad do table.remove(Result) end
        return table.concat(Result)
    end

    local function Encode()
        local Data = {}
        for Key, Entry in Registry do
            if State[Key] ~= nil and State[Key] ~= Entry.Default then
                Data[Key] = State[Key]
            end
        end
        local Json = HttpService:JSONEncode(Data)
        local B64, Pad = ToBase64(Json)
        local Sum = 0
        for i = 1, #Json do Sum += string.byte(Json, i) end
        local Check = Sum % 97
        return ConfigVersion .. B64 .. tostring(Pad) .. string.format("%02d", Check)
    end

    local function Decode(Text)
        if type(Text) ~= "string" or #Text < 8 then return nil end
        if Text:sub(1, 2) ~= ConfigVersion then return nil end
        local Pad = tonumber(Text:sub(-3, -3))
        local Check = tonumber(Text:sub(-2))
        if not Pad or not Check then return nil end
        local B64 = Text:sub(3, -4)
        local Json = FromBase64(B64, Pad)
        local Sum = 0
        for i = 1, #Json do Sum += string.byte(Json, i) end
        if Sum % 97 ~= Check then return nil end
        local Ok, Data = pcall(function() return HttpService:JSONDecode(Json) end)
        if not Ok or type(Data) ~= "table" then return nil end
        return Data
    end

    Feature.CreateConfigId = function()
        local Id = Encode()
        return Id, CopyText(Id)
    end

    Feature.LoadConfig = function(Text)
        local Data = Decode(Text)
        if not Data then return false end
        for Key, Entry in Registry do
            local Target = Data[Key]
            if Target == nil then Target = Entry.Default end
            if type(Target) == type(Entry.Default) and State[Key] ~= Target then
                State[Key] = Target
                if Entry.Kind ~= "toggle" then Saved[Key] = Target end
                pcall(function()
                    local Element = Entry.Element
                    if Element then
                        if Entry.Kind == "dropdown" and Element.Select then
                            Element:Select(Target)
                        elseif Element.Set then
                            Element:Set(Target)
                        end
                    end
                end)
                if Entry.Callback then task.spawn(Entry.Callback, Target) end
            end
        end
        SaveSettings()
        if Feature.AfterLoad then Feature.AfterLoad() end
        return true
    end
end

do
    local EmoteState = { Emoting = false, Track = nil, Speed = 16, Jump = 50, Rotation = nil }
    local EmoteModules = {}
    local EmotesFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Emotes")

    if EmotesFolder then
        for _, Object in EmotesFolder:GetDescendants() do
            if Object:IsA("ModuleScript") then table.insert(EmoteModules, Object) end
        end
        table.sort(EmoteModules, function(A, B) return A.Name < B.Name end)
    end

    Feature.EmoteNames = {}
    for _, Module in EmoteModules do table.insert(Feature.EmoteNames, Module.Name) end
    if #Feature.EmoteNames == 0 then Feature.EmoteNames = { "None" } end

    Feature.StopEmote = function()
        if not EmoteState.Emoting then return end
        EmoteState.Emoting = false
        if EmoteState.Rotation then
            EmoteState.Rotation:Disconnect()
            EmoteState.Rotation = nil
        end
        local Character = LocalCharacter
        if Character then
            local Root = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local Effects = Character:FindFirstChild("PlayerEmoteVFX")
            if Effects then Effects:Destroy() end
            if Root then
                Root.Anchored = false
                local Sound = Root:FindFirstChild("EmoteSound")
                if Sound then Sound:Destroy() end
                local Attachment = Root:FindFirstChild("SAB_EmoteAttachment")
                if Attachment then Attachment:Destroy() end
            end
            if Humanoid then
                Humanoid.WalkSpeed = EmoteState.Speed
                Humanoid.JumpPower = EmoteState.Jump
            end
        end
        if EmoteState.Track then
            pcall(function() EmoteState.Track:Stop() end)
            EmoteState.Track = nil
        end
    end

    Feature.PlayEmote = function()
        local Module
        for _, Candidate in EmoteModules do
            if Candidate.Name == State.EmoteSelect then Module = Candidate; break end
        end
        if not Module then return end
        if EmoteState.Emoting then
            Feature.StopEmote()
            task.wait(0.1)
        end
        local Character = LocalCharacter
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Root = Character and (Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart)
        local Animator = Humanoid and Humanoid:WaitForChild("Animator", 2)
        if not Humanoid or not Root or not Animator then return end
        local Loaded, Data = pcall(require, Module)
        if not Loaded or type(Data) ~= "table" or not Data.AssetID then return end
        EmoteState.Emoting = true
        EmoteState.Speed = Humanoid.WalkSpeed
        EmoteState.Jump = Humanoid.JumpPower
        Humanoid.WalkSpeed = 0
        Humanoid.JumpPower = 0
        Root.Anchored = true
        local Animation = Instance.new("Animation")
        Animation.AnimationId = tostring(Data.AssetID)
        EmoteState.Track = Animator:LoadAnimation(Animation)
        EmoteState.Track.Looped = true
        EmoteState.Track:Play()
        if EmoteState.Rotation then EmoteState.Rotation:Disconnect() end
        EmoteState.Rotation = RunService.RenderStepped:Connect(function()
            local Camera = workspace.CurrentCamera
            if not EmoteState.Emoting or not Camera or not LocalRoot or LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson then return end
            local _, CameraY = Camera.CFrame:ToEulerAnglesYXZ()
            LocalRoot.CFrame = CFrame.new(LocalRoot.Position) * CFrame.Angles(0, CameraY, 0)
        end)
        if Data.SFX then
            local Old = Root:FindFirstChild("EmoteSound")
            if Old then Old:Destroy() end
            local Sound = Instance.new("Sound")
            Sound.Name = "EmoteSound"
            Sound.SoundId = tostring(Data.SFX)
            Sound.Volume = 1
            Sound.Looped = true
            Sound.Parent = Root
            Sound:Play()
        end
        local Attachment = Instance.new("Attachment")
        Attachment.Name = "SAB_EmoteAttachment"
        Attachment.Parent = Root
        local Burst = Instance.new("ParticleEmitter")
        Burst.Name = "EmoteBurst"
        Burst.Texture = "rbxassetid://635533604"
        Burst.Rate = 60
        Burst.Speed = NumberRange.new(2, 5)
        Burst.Lifetime = NumberRange.new(0.5, 1.2)
        Burst.Drag = 5
        Burst.Parent = Attachment
    end

    LocalPlayer.CharacterRemoving:Connect(function()
        if EmoteState.Emoting then Feature.StopEmote() end
    end)

    table.insert(CharacterCallbacks, function()
        task.wait(0.5)
        if EmoteState.Emoting then Feature.StopEmote() end
    end)
end

do
    local BaseAnimations = {}
    local Entries = {}
    local CurrentTracks = {}
    local MoveConnection

    local function AnimId(Value)
        return Value and tostring(Value) or nil
    end

    local function CollectBase()
        BaseAnimations = {}
        local Assets = ReplicatedStorage:FindFirstChild("Assets")
        if not Assets then return end
        for _, Role in { "Killers", "Survivors" } do
            local Folder = Assets:FindFirstChild(Role)
            if Folder then
                for _, CharFolder in Folder:GetChildren() do
                    local Config = CharFolder:IsA("Folder") and CharFolder:FindFirstChild("Config")
                    if Config and Config:IsA("ModuleScript") then
                        local Loaded, Data = pcall(require, Config)
                        if Loaded and type(Data) == "table" and Data.Animations then
                            local Anims = Data.Animations
                            BaseAnimations[CharFolder.Name] = {
                                Idle = AnimId(Anims.Idle),
                                Walk = AnimId(Anims.Walk),
                                Run = AnimId(Anims.Run),
                                DisplayName = Data.DisplayName or CharFolder.Name
                            }
                        end
                    end
                end
            end
        end
    end

    local function BuildEntries()
        Entries = {}
        local Seen = {}
        local NameCount = {}
        local function Add(Name, Idle, Walk, Run)
            local Key = Idle .. "|" .. Walk .. "|" .. Run
            if Seen[Key] then return end
            Seen[Key] = true
            NameCount[Name] = (NameCount[Name] or 0) + 1
            if NameCount[Name] > 1 then Name = Name .. " (" .. NameCount[Name] .. ")" end
            table.insert(Entries, { Name = Name, Idle = Idle, Walk = Walk, Run = Run })
        end
        for CharName, Data in BaseAnimations do
            Add(Data.DisplayName or CharName, Data.Idle or "", Data.Walk or "", Data.Run or "")
        end
        local Assets = ReplicatedStorage:FindFirstChild("Assets")
        local Skins = Assets and Assets:FindFirstChild("Skins")
        if not Skins then return end
        for _, Role in { "Killers", "Survivors" } do
            local RoleFolder = Skins:FindFirstChild(Role)
            if RoleFolder then
                for _, CharFolder in RoleFolder:GetChildren() do
                    if CharFolder:IsA("Folder") then
                        local BaseData = BaseAnimations[CharFolder.Name]
                        for _, Skin in CharFolder:GetChildren() do
                            local Config = Skin:IsA("Folder") and Skin:FindFirstChild("Config")
                            if Config and Config:IsA("ModuleScript") then
                                local Loaded, Data = pcall(require, Config)
                                if Loaded and type(Data) == "table" and Data.Animations then
                                    local Anims = Data.Animations
                                    local Idle = AnimId(Anims.Idle) or (BaseData and BaseData.Idle)
                                    local Walk = AnimId(Anims.Walk) or (BaseData and BaseData.Walk)
                                    local Run = AnimId(Anims.Run) or (BaseData and BaseData.Run)
                                    if Idle and Walk and Run then
                                        Add(Data.DisplayName or Skin.Name, Idle, Walk, Run)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local function Names()
        local List = {}
        for _, Entry in Entries do table.insert(List, Entry.Name) end
        return #List > 0 and List or { "None" }
    end

    Feature.StopAnimation = function()
        if MoveConnection then
            MoveConnection:Disconnect()
            MoveConnection = nil
        end
        for _, Track in CurrentTracks do
            pcall(function()
                Track:Stop()
                Track:Destroy()
            end)
        end
        CurrentTracks = {}
    end

    Feature.ApplyAnimation = function()
        Feature.StopAnimation()
        local Entry
        for _, Candidate in Entries do
            if Candidate.Name == State.AnimSelect then Entry = Candidate; break end
        end
        local Character = LocalCharacter
        local Humanoid = LocalHumanoid
        if not Entry or not Character or not Humanoid then return end
        local Animator = Humanoid:FindFirstChildOfClass("Animator")
        if not Animator then
            Animator = Instance.new("Animator")
            Animator.Parent = Humanoid
        end
        local Loaded = {}
        for _, Kind in { "Idle", "Walk", "Run" } do
            local Id = Entry[Kind]
            if Id and Id ~= "" then
                local Animation = Instance.new("Animation")
                Animation.AnimationId = Id
                local Track = Animator:LoadAnimation(Animation)
                Track.Priority = Enum.AnimationPriority.Movement
                Loaded[Kind] = Track
            end
        end
        CurrentTracks = Loaded
        MoveConnection = RunService.RenderStepped:Connect(function()
            if not Character.Parent then Feature.StopAnimation(); return end
            local NewTrack
            if Humanoid.MoveDirection.Magnitude > 0.1 then
                if Humanoid.WalkSpeed >= 20 then
                    NewTrack = Loaded.Run or Loaded.Walk
                else
                    NewTrack = Loaded.Walk or Loaded.Run
                end
            else
                NewTrack = Loaded.Idle
            end
            for _, Track in Loaded do
                if Track.IsPlaying and Track ~= NewTrack then Track:Stop() end
            end
            if NewTrack and not NewTrack.IsPlaying then NewTrack:Play() end
        end)
    end

    Feature.RefreshAnimations = function()
        CollectBase()
        BuildEntries()
        return Names()
    end

    CollectBase()
    BuildEntries()
    Feature.AnimNames = Names()

    table.insert(CharacterCallbacks, function()
        task.wait(0.5)
        if next(CurrentTracks) then Feature.StopAnimation() end
    end)
end

do
    local MusicTracks = {
        ["MADE JUST 4 U"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7277.mp3",
        ["Hello"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7280.mp3",
        ["APOCOOLYPSE"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7282.mp3",
        ["A BRAVE SOUL"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7283.mp3",
        ["Profitable Passion"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7287.mp3",
        ["ARTIST BLOCK:Reprise"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7290.mp3",
        ["Faith's Answer"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7292.mp3",
        ["Teapot Palace"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7295.mp3",
        ["Ready To Die"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/IMG_7309.mp3",
        ["Escape The Necrobloxians"] = "https://raw.githubusercontent.com/FixFox550/FixFox/refs/heads/main/Hwoowowow.mp3"
    }

    Feature.MusicNames = {}
    for Name in MusicTracks do table.insert(Feature.MusicNames, Name) end
    table.sort(Feature.MusicNames)

    local MusicFolder = SettingsFolder .. "/Music"
    local FileSupport = FilesSupported and typeof(getcustomasset) == "function"

    if FileSupport then
        pcall(function()
            if not isfolder(MusicFolder) then makefolder(MusicFolder) end
        end)
    end

    local Music = { On = false, Cached = {}, OriginalId = nil, Token = 0, CachedSound = nil, LastCheck = 0, Preview = nil }
    local InFlight = {}

    local function Fetch(Name)
        if not FileSupport then return nil end
        if Music.Cached[Name] then return Music.Cached[Name] end
        local Url = MusicTracks[Name]
        if not Url then return nil end
        local Path = MusicFolder .. "/" .. Name:gsub("[^%w]", "_") .. ".mp3"
        if not isfile(Path) then
            local Ok, Data = pcall(function() return game:HttpGet(Url) end)
            if not Ok or not Data then return nil end
            writefile(Path, Data)
        end
        local Ok, Asset = pcall(getcustomasset, Path)
        if Ok and Asset then
            Music.Cached[Name] = Asset
            return Asset
        end
        return nil
    end

    local function FetchAsync(Name, Callback)
        if Music.Cached[Name] then
            if Callback then Callback(Music.Cached[Name]) end
            return
        end
        if InFlight[Name] then return end
        InFlight[Name] = true
        task.spawn(function()
            local Asset = Fetch(Name)
            InFlight[Name] = nil
            if Asset and Callback then Callback(Asset) end
        end)
    end

    local function GetSound()
        local Now = os.clock()
        if Music.CachedSound and Music.CachedSound.Parent and Now - Music.LastCheck < 0.5 then
            return Music.CachedSound
        end
        Music.LastCheck = Now
        local Themes = workspace:FindFirstChild("Themes")
        local Sound = (Themes and Themes:FindFirstChild("LastSurvivor")) or workspace:FindFirstChild("LastSurvivor", true) or SoundService:FindFirstChild("LastSurvivor", true)
        if Sound and Sound:IsA("Sound") then
            Music.CachedSound = Sound
            return Sound
        end
        Music.CachedSound = nil
        return nil
    end

    local function Replace(Sound, Asset)
        if not Music.OriginalId then Music.OriginalId = Sound.SoundId end
        if Sound.SoundId ~= Asset then
            Sound.SoundId = Asset
            Sound:Stop()
            task.wait(0.05)
            Sound:Play()
        elseif not Sound.IsPlaying then
            Sound:Play()
        end
    end

    Feature.SetLms = function(Enabled)
        Music.Token += 1
        Music.On = Enabled
        if Enabled then
            local Token = Music.Token
            FetchAsync(State.LmsTrack)
            task.spawn(function()
                while Token == Music.Token do
                    pcall(function()
                        local Sound = GetSound()
                        if Sound then
                            local Asset = Music.Cached[State.LmsTrack]
                            if Asset then Replace(Sound, Asset) else FetchAsync(State.LmsTrack) end
                        end
                    end)
                    task.wait(1)
                end
            end)
        else
            pcall(function()
                local Sound = GetSound()
                if Sound and Music.OriginalId then
                    Sound.SoundId = Music.OriginalId
                    Sound:Stop()
                    task.wait(0.05)
                    Sound:Play()
                end
            end)
        end
    end

    Feature.PreloadMusic = function()
        task.spawn(function()
            if not FileSupport then
                Notify("Music", "Your executor does not support custom audio", 4)
                return
            end
            for _, Name in Feature.MusicNames do
                FetchAsync(Name)
                task.wait(0.05)
            end
            Notify("Music", "Preload complete", 3)
        end)
    end

    Feature.StopPreview = function()
        if Music.Preview then
            Music.Preview:Stop()
            Music.Preview:Destroy()
            Music.Preview = nil
            Notify("Music", "Preview stopped", 2)
        end
    end

    Feature.StartPreview = function()
        task.spawn(function()
            local Asset = Fetch(State.LmsTrack)
            if not Asset then
                Notify("Music", "Failed to load the song", 3)
                return
            end
            if Music.Preview then
                Music.Preview:Stop()
                Music.Preview:Destroy()
            end
            local Sound = Instance.new("Sound")
            Sound.Name = "FluxSakenPreview"
            Sound.SoundId = Asset
            Sound.Volume = 1
            Sound.Parent = SoundService
            Sound:Play()
            Music.Preview = Sound
            Notify("Music", "Playing: " .. State.LmsTrack, 2)
        end)
    end
end

do
    local TrickMonitors = {}
    local TrickConnection
    local TrickFolder

    task.spawn(function()
        local Ok, Folder = pcall(function()
            return ReplicatedStorage:WaitForChild("Assets", 10):WaitForChild("Survivors", 10):WaitForChild("Veeronica", 10):WaitForChild("Behavior", 10)
        end)
        if Ok and Folder then TrickFolder = Folder end
    end)

    local function MonitorHighlight(Highlight)
        if not Highlight or TrickMonitors[Highlight] then return end
        local Connections = {}
        local Previous = false
        local function Cleanup()
            for _, Connection in Connections do
                if Connection.Connected then Connection:Disconnect() end
            end
            TrickMonitors[Highlight] = nil
        end
        local function Changed()
            if not State.AutoTrick then return end
            if not Highlight.Parent then Cleanup(); return end
            local Adornee = Highlight.Adornee
            local Current = Adornee ~= nil and LocalCharacter ~= nil and (Adornee == LocalCharacter or Adornee:IsDescendantOf(LocalCharacter))
            if Current and not Previous then
                local MainUI = PlayerGui:FindFirstChild("MainUI")
                local Button = MainUI and MainUI:FindFirstChild("SprintingButton")
                if Button and typeof(getconnections) == "function" then
                    for _, Connection in getconnections(Button.MouseButton1Down) do
                        pcall(function() Connection:Fire() end)
                    end
                end
            end
            Previous = Current
        end
        table.insert(Connections, Highlight:GetPropertyChangedSignal("Adornee"):Connect(Changed))
        table.insert(Connections, Highlight.AncestryChanged:Connect(function(_, Parent)
            if not Parent then Cleanup() else Changed() end
        end))
        TrickMonitors[Highlight] = Cleanup
        task.spawn(Changed)
    end

    Feature.SetAutoTrick = function(Enabled)
        if Enabled then
            if not TrickFolder or TrickConnection then return end
            for _, Descendant in TrickFolder:GetDescendants() do
                if Descendant:IsA("Highlight") then MonitorHighlight(Descendant) end
            end
            TrickConnection = TrickFolder.DescendantAdded:Connect(function(Child)
                if Child:IsA("Highlight") then MonitorHighlight(Child) end
            end)
        else
            if TrickConnection then
                TrickConnection:Disconnect()
                TrickConnection = nil
            end
            for _, Cleanup in table.clone(TrickMonitors) do pcall(Cleanup) end
            TrickMonitors = {}
        end
    end

    local ShiftConnection
    local ControlActive = false
    local ControlConnection
    local SavedHumanoid = {}

    local function SetShiftlock(Enabled)
        if ShiftConnection then
            ShiftConnection:Disconnect()
            ShiftConnection = nil
        end
        if Enabled then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            ShiftConnection = RunService.RenderStepped:Connect(function()
                local Camera = workspace.CurrentCamera
                if LocalRoot and Camera then
                    local Look = Camera.CFrame.LookVector
                    LocalRoot.CFrame = CFrame.new(LocalRoot.Position, Vector3.new(Look.X + LocalRoot.Position.X, LocalRoot.Position.Y, Look.Z + LocalRoot.Position.Z))
                end
            end)
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end

    local function StartOverride()
        if ControlActive or not LocalHumanoid then return end
        ControlActive = true
        local Humanoid = LocalHumanoid
        SavedHumanoid[Humanoid] = { WalkSpeed = Humanoid.WalkSpeed, AutoRotate = Humanoid.AutoRotate }
        pcall(function()
            Humanoid.WalkSpeed = 60
            Humanoid.AutoRotate = false
        end)
        SetShiftlock(true)
        ControlConnection = RunService.RenderStepped:Connect(function()
            local Root = LocalRoot
            if not Humanoid.Parent or not Root then return end
            pcall(function()
                Humanoid.WalkSpeed = 60
                Humanoid.AutoRotate = false
            end)
            local Look = Root.CFrame.LookVector
            local Flat = Vector3.new(Look.X, 0, Look.Z)
            if Flat.Magnitude > 0 then Humanoid:Move(Flat.Unit) end
        end)
    end

    local function StopOverride()
        if not ControlActive then return end
        ControlActive = false
        if ControlConnection then
            ControlConnection:Disconnect()
            ControlConnection = nil
        end
        SetShiftlock(false)
        local Humanoid = LocalHumanoid
        if Humanoid then
            pcall(function()
                local Saved = SavedHumanoid[Humanoid]
                if Saved then
                    Humanoid.WalkSpeed = Saved.WalkSpeed
                    SavedHumanoid[Humanoid] = nil
                end
                Humanoid.AutoRotate = true
                Humanoid:Move(Vector3.zero)
            end)
        end
    end

    local function IsPlayingAnimation(TargetId)
        if not LocalHumanoid then return false end
        for _, Track in LocalHumanoid:GetPlayingAnimationTracks() do
            local Id = Track.Animation and tostring(Track.Animation.AnimationId or ""):match("%d+")
            if Id == TargetId then return true end
        end
        return false
    end

    local SprayPhase = 0
    local SprayBase

    RunService.RenderStepped:Connect(function(Delta)
        if State.Sk8Control then
            if IsPlayingAnimation("117058860640843") then StartOverride() else StopOverride() end
        elseif ControlActive then
            StopOverride()
        end
        if not State.FastSpray or not IsPlayingAnimation("96618767275101") or not LocalRoot then
            SprayPhase = 0
            SprayBase = nil
            return
        end
        if not SprayBase or math.abs(math.sin(SprayPhase)) < 0.05 then
            SprayBase = LocalRoot.CFrame
        end
        SprayPhase += Delta * (math.pi * (State.SpraySpeed or 0.5))
        LocalRoot.CFrame = SprayBase + SprayBase.LookVector * (-math.sin(SprayPhase) * 2)
    end)

    table.insert(CharacterCallbacks, function()
        if ShiftConnection then
            ShiftConnection:Disconnect()
            ShiftConnection = nil
        end
        ControlActive = false
        SavedHumanoid = {}
        SprayPhase = 0
        SprayBase = nil
    end)
end

local TT = {
    Running = false,
    MoreDirectRN = false,
    MoreDirectEnd = false,
    DoitMate = false,
    LastKillerModel = nil,
    LastKillerPos = nil,
    SmoothedSpeed = 0
}

local function TT_GetKiller()
    if not KillersFolder then return nil end
    for _, inst in ipairs(KillersFolder:GetDescendants()) do
        if inst:IsA("Model") then
            local hum = inst:FindFirstChildOfClass("Humanoid")
            local hrp = inst:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then return inst end
        end
    end
    return nil
end

local function TT_GetPing()
    local ok, val = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and val then return val end
    local ok2, val2 = pcall(function() return LocalPlayer:GetNetworkPing() * 1000 end)
    if ok2 and val2 then return val2 end
    return 20
end

local function TT_CheckDist(hrp1, hrp2, range)
    if not hrp1 or not hrp2 then return false end
    return (hrp1.Position - hrp2.Position).Magnitude <= range
end

local function TT_GetSprintRef()
    if SpeedMultipliers and SpeedMultipliers:FindFirstChild("Sprinting") then
        return SpeedMultipliers.Sprinting
    end
    return nil
end

local function TT_RunBackstab()
    if not State.BackstabEnabled or TT.Running then return end
    TT.Running = true
    local character = LocalPlayer.Character
    if not character then TT.Running = false; return end
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then TT.Running = false; return end
    task.wait(State.TTStartDelay or 0.05)
    if not character.Parent then TT.Running = false; return end

    local place = Instance.new("Part")
    place.Name = "place"
    place.Size = Vector3.new(2, 2, 2)
    place.Transparency = 0
    place.CanCollide = false
    place.Anchored = true
    place.Parent = character

    local originalPrimaryPart = character.PrimaryPart
    local sprintRef = TT_GetSprintRef()
    local oldspeed = sprintRef and sprintRef.Value or nil

    if State.TTMoreDirect then
        TT.MoreDirectRN = true
        task.wait(0.01)
        TT.MoreDirectRN = false
    end

    local startTime = os.clock()
    while os.clock() - startTime < (State.TTDuration or 0.2) do
        if not character.Parent or not place.Parent or not State.BackstabEnabled then break end
        if sprintRef then sprintRef.Value = 0 end
        TT.DoitMate = true
        RunService.PreRender:Wait()
    end

    if place and place.Parent then place:Destroy() end
    if character and character.Parent then character.PrimaryPart = originalPrimaryPart end
    if sprintRef and oldspeed then sprintRef.Value = oldspeed end
    TT.DoitMate = false

    if State.TTMoreDirect then
        TT.MoreDirectRN = true
        task.wait(0.01)
        TT.MoreDirectEnd = true
        TT.MoreDirectRN = false
        task.wait(0.01)
        TT.MoreDirectEnd = false
    end

    TT.Running = false
end

local function TT_RunDashstab()
    if not State.TTDashstab or TT.Running then return end
    TT.Running = true
    local character = LocalPlayer.Character
    if not character then TT.Running = false; return end
    task.wait(State.TTDSStartDelay or 0.1)
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not character.Parent or not hrp then TT.Running = false; return end

    local place = Instance.new("Part")
    place.Name = "place"
    place.Size = Vector3.new(2, 2, 2)
    place.Transparency = 0
    place.CanCollide = false
    place.Anchored = true
    place.Parent = character

    local originalPrimaryPart = character.PrimaryPart
    local sprintRef = TT_GetSprintRef()
    local oldspeed = sprintRef and sprintRef.Value or nil

    if State.TTMoreDirect then
        TT.MoreDirectRN = true
        task.wait(0.01)
        TT.MoreDirectRN = false
    end

    local startTime = os.clock()
    while os.clock() - startTime < (State.TTDuration or 0.2) do
        if not character.Parent or not place.Parent or not State.TTDashstab then break end
        if sprintRef then sprintRef.Value = 0 end
        TT.DoitMate = true
        RunService.PreRender:Wait()
    end

    if sprintRef and oldspeed then sprintRef.Value = oldspeed end
    TT.DoitMate = false

    if State.TTMoreDirect then
        TT.MoreDirectRN = true
        task.wait(0.001)
        TT.MoreDirectEnd = true
        TT.MoreDirectRN = false
        task.wait(0.001)
        TT.MoreDirectEnd = false
    end

    if place and place.Parent then place:Destroy() end
    if character and character.Parent then character.PrimaryPart = originalPrimaryPart end
    TT.Running = false
end

local TT_NetworkRef
local TT_CharRepRef
pcall(function()
    TT_NetworkRef = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"))
    TT_CharRepRef = require(ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Player"):WaitForChild("Game"):WaitForChild("CharacterReplication"))
end)

if TT_NetworkRef and TT_CharRepRef and typeof(hookfunction) == "function" then
    pcall(function()
        local oldFireServerConnection
        oldFireServerConnection = hookfunction(TT_NetworkRef.FireServerConnection, function(self, connectionName, eventType, ...)
            local args = { ... }
            if connectionName == "UpdateCharacterPosition" then
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local killerModel = TT_GetKiller()
                if killerModel then
                    local killerHrp = killerModel:FindFirstChild("HumanoidRootPart")
                    if killerHrp and hrp then
                        local targetCFrame = killerHrp.CFrame * CFrame.new(0, 0, State.TTBehindStuds or 4)
                        local targetdirect = hrp.CFrame * CFrame.new(0, -90000, 0)
                        local targetdirectend = hrp.CFrame * CFrame.new(0, 0, 0)
                        if TT.MoreDirectRN then
                            args[1] = TT_CharRepRef.Serialize(targetdirect, hrp.AssemblyLinearVelocity)
                        elseif TT.MoreDirectEnd then
                            args[1] = TT_CharRepRef.Serialize(targetdirectend, hrp.AssemblyLinearVelocity)
                        elseif TT.DoitMate then
                            args[1] = TT_CharRepRef.Serialize(targetCFrame, hrp.AssemblyLinearVelocity)
                        end
                    end
                end
            end
            return oldFireServerConnection(self, connectionName, eventType, unpack(args))
        end)
    end)
end

RunService.Heartbeat:Connect(function(dt)
    if State.TTAutoStuds then
        local killer = TT_GetKiller()
        if killer then
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp then
                local currentPos = hrp.Position
                local rawSpeed = 0
                if TT.LastKillerModel == killer and TT.LastKillerPos then
                    local horizontalDelta = Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(TT.LastKillerPos.X, 0, TT.LastKillerPos.Z)
                    rawSpeed = horizontalDelta.Magnitude / dt
                end
                TT.LastKillerModel = killer
                TT.LastKillerPos = currentPos
                TT.SmoothedSpeed = TT.SmoothedSpeed + (rawSpeed - TT.SmoothedSpeed) * math.min(dt * 15, 1)
                local finalSpeed = math.clamp(TT.SmoothedSpeed, 0, 30)
                local studsAtRun = State.TTAutoRunStuds or 3.4
                if State.TTDetectPing then
                    local ping = TT_GetPing()
                    local clampedPing = math.max(ping, 20)
                    studsAtRun = studsAtRun - ((clampedPing - 20) / 100) * 1.5
                    studsAtRun = math.max(studsAtRun, 1.0)
                end
                local slope = ((State.TTAutoStandStuds or 5.5) - studsAtRun) / 26.0
                State.TTBehindStuds = (State.TTAutoStandStuds or 5.5) - (finalSpeed * slope)
            else
                TT.LastKillerModel = nil
            end
        else
            TT.LastKillerModel = nil
            TT.SmoothedSpeed = 0
        end
    else
        TT.LastKillerModel = nil
        TT.SmoothedSpeed = 0
    end
end)

table.insert(CharacterCallbacks, function()
    local Humanoid = LocalHumanoid
    local Animator = Humanoid and (Humanoid:FindFirstChildOfClass("Animator") or Humanoid:WaitForChild("Animator", 5))
    if not Animator then return end
    Animator.AnimationPlayed:Connect(function(Track)
        if not Track or not Track.Animation then return end
        local killer = TT_GetKiller()
        if not killer then return end
        local id = tostring(Track.Animation.AnimationId or ""):gsub("%D", "")
        if (id == "100725497418533" or id == "106086955212611") and State.BackstabEnabled then
            if State.TTDistCheck then
                if not TT_CheckDist(LocalRoot, killer:FindFirstChild("HumanoidRootPart"), State.TTDistCheckStud or 7) then return end
            end
            task.spawn(TT_RunBackstab)
        elseif (id == "89448354637442" or id == "107640065977686") and State.TTDashstab then
            if State.TTDistCheck then
                if not TT_CheckDist(LocalRoot, killer:FindFirstChild("HumanoidRootPart"), State.TTDistCheckStud or 7) then return end
            end
            task.spawn(TT_RunDashstab)
        end
    end)
end)

local MinigameSolver = {
    Enabled = false,
    Generation = 0,
    LockBoard = nil,
    Installed = false
}

local MinigameFolder
local FlowBoardModule
local LockBoardModule
local FlowInputModule
local GearInputModule
local LockInputModule
local ConnectInputModule

pcall(function()
    MinigameFolder = ReplicatedStorage.Systems.Player.Game.Minigames
    FlowBoardModule = require(ReplicatedStorage.Modules.Minigames.FlowBoard)
    LockBoardModule = require(ReplicatedStorage.Modules.Minigames.LockBoard)
    FlowInputModule = require(MinigameFolder.FlowClientMinigame.FlowInput)
    GearInputModule = require(MinigameFolder.GearClientMinigame.GearInput)
    LockInputModule = require(MinigameFolder.LockClientMinigame.LockInput)
    ConnectInputModule = require(MinigameFolder.ConnectClientMinigame.ConnectInput)
end)

local function solverDelay()
    return math.max(0, (State.FlowCellSpeed or 50) / 1000)
end

local function connectSolverDelay()
    return math.max(0, (State.ConnectPairDelay or 1000) / 1000)
end

local function waitForSolver(object)
    while object and not object.Ended and not MinigameSolver.Enabled do
        task.wait(0.05)
    end
    if not (object and not object.Ended and MinigameSolver.Enabled) then return false end
    local started = os.clock()
    while object and not object.Ended and MinigameSolver.Enabled and os.clock() - started < (State.MinGameStartDelay or 1.5) do
        task.wait(0.05)
    end
    return object and not object.Ended and MinigameSolver.Enabled
end

local function solveFlowBoard(board)
    if not FlowBoardModule then return nil end
    local size, pairMap = board.Size, board.Pairs
    local occupied, answer = {}, {}
    local directions = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
    local endpointOwner = {}

    for color, pair in pairs(pairMap) do
        endpointOwner[pair[1]], endpointOwner[pair[2]] = color, color
    end

    local remaining = {}
    for color in pairs(pairMap) do table.insert(remaining, color) end

    local function candidates(color, limit)
        local pair = pairMap[color]
        local from, target = pair[1], pair[2]
        local results, path, seen = {}, { from }, { [from] = true }

        local function distance(cell)
            local r, c = FlowBoardModule.ToRowCol(size, cell)
            local tr, tc = FlowBoardModule.ToRowCol(size, target)
            return math.abs(r - tr) + math.abs(c - tc)
        end

        local function walk(cell)
            if #results >= limit then return end
            if cell == target then
                table.insert(results, table.clone(path))
                return
            end
            local row, col = FlowBoardModule.ToRowCol(size, cell)
            local nextCells = {}
            for _, d in ipairs(directions) do
                local nr, nc = row + d[1], col + d[2]
                if nr >= 1 and nr <= size and nc >= 1 and nc <= size then
                    local n = FlowBoardModule.ToIndex(size, nr, nc)
                    local owner = endpointOwner[n]
                    if not seen[n] and not occupied[n] and (not owner or (owner == color and n == target)) then
                        table.insert(nextCells, n)
                    end
                end
            end
            table.sort(nextCells, function(a, b) return distance(a) < distance(b) end)
            for _, n in ipairs(nextCells) do
                seen[n] = true
                table.insert(path, n)
                walk(n)
                path[#path] = nil
                seen[n] = nil
                if #results >= limit then break end
            end
        end

        walk(from)
        table.sort(results, function(a, b) return #a < #b end)
        return results
    end

    local function search(colors)
        if #colors == 0 then return true end
        local bestIndex, bestPaths
        for i, color in ipairs(colors) do
            local list = candidates(color, 300)
            if #list == 0 then return false end
            if not bestPaths or #list < #bestPaths then
                bestIndex, bestPaths = i, list
            end
        end
        local color = colors[bestIndex]
        local nextColors = table.clone(colors)
        table.remove(nextColors, bestIndex)
        for _, path in ipairs(bestPaths) do
            for _, cell in ipairs(path) do occupied[cell] = true end
            answer[color] = path
            if search(nextColors) then return true end
            answer[color] = nil
            for _, cell in ipairs(path) do occupied[cell] = nil end
        end
        return false
    end

    return search(remaining) and answer or nil
end

local function installMinigameHooks()
    if MinigameSolver.Installed then return end
    if not (FlowBoardModule and LockBoardModule and FlowInputModule and GearInputModule and LockInputModule and ConnectInputModule) then return end
    MinigameSolver.Installed = true

    local oldLockBoardNew = LockBoardModule.new
    LockBoardModule.new = function(...)
        local board = oldLockBoardNew(...)
        MinigameSolver.LockBoard = board
        return board
    end

    local oldFlowNew = FlowInputModule.new
    FlowInputModule.new = function(board, renderer, callbacks)
        local object = oldFlowNew(board, renderer, callbacks)
        local token = MinigameSolver.Generation
        task.spawn(function()
            if not waitForSolver(object) then return end
            task.wait(solverDelay())
            local paths = solveFlowBoard(board)
            if not paths then
                warn("[Generator Solver] Flow solution was not found")
                return
            end
            for color, path in pairs(paths) do
                if not (MinigameSolver.Enabled and object and not object.Ended) then return end
                local drawing = board:Begin(path[1])
                renderer:Render()
                task.wait(solverDelay())
                for index = 2, #path do
                    if not (MinigameSolver.Enabled and object and not object.Ended) then return end
                    board:Step(drawing, path[index], 0)
                    renderer:Render()
                    task.wait(solverDelay())
                end
                board:Release(drawing, true)
                renderer:Render()
                task.wait(solverDelay())
            end
            if MinigameSolver.Enabled and object and not object.Ended and board:IsSolved() then
                object:__finish()
                callbacks.OnSolved()
            end
        end)
        return object
    end

    local oldConnectNew = ConnectInputModule.new
    ConnectInputModule.new = function(board, renderer, callbacks)
        local object = oldConnectNew(board, renderer, callbacks)
        local token = MinigameSolver.Generation
        task.spawn(function()
            if not waitForSolver(object) then return end
            task.wait(connectSolverDelay())
            for blob in pairs(board.Blobs) do
                if not (MinigameSolver.Enabled and object and not object.Ended) then return end
                if not board:GetLink(blob) then
                    local mate = board:GetMate(blob)
                    if mate then
                        board:Connect(blob, mate)
                        renderer:Render()
                        task.wait(connectSolverDelay())
                    end
                end
            end
            if MinigameSolver.Enabled and object and not object.Ended and board:IsSolved() then
                object:__finish()
                callbacks.OnSolved()
            end
        end)
        return object
    end

    local oldGearNew = GearInputModule.new
    GearInputModule.new = function(getCenter, callbacks, enabled)
        local object = oldGearNew(getCenter, callbacks, enabled)
        local token = MinigameSolver.Generation
        task.spawn(function()
            if not waitForSolver(object) then return end
            task.wait(math.max(0.55, solverDelay()))
            for _ = 1, 100 do
                if not (MinigameSolver.Enabled and object and not object.Ended) then return end
                callbacks.OnTurn(90)
                task.wait(math.max(0, (State.GearTurnSpeed or 30) / 1000))
            end
        end)
        return object
    end

    local oldLockNew = LockInputModule.new
    LockInputModule.new = function(ui, callbacks)
        local object = oldLockNew(ui, callbacks)
        local board = MinigameSolver.LockBoard
        local token = MinigameSolver.Generation
        task.spawn(function()
            if not waitForSolver(object) then return end
            while MinigameSolver.Enabled and object and not object.Ended and board and not board:IsBroken() do
                local now = workspace:GetServerTimeNow()
                if board:IsOnTarget(board:AngleAt(now)) then
                    callbacks.OnPress()
                    task.wait(math.max(0.08, solverDelay()))
                else
                    RunService.Heartbeat:Wait()
                end
            end
        end)
        return object
    end
end

pcall(installMinigameHooks)

local PlusAnimations = {}
pcall(function()
    local Assets = ReplicatedStorage:FindFirstChild("Assets")
    if not Assets then return end
    if typeof(require) ~= "function" then return end
    local function scan(folder)
        if not folder then return end
        for _, child in folder:GetChildren() do
            local cfg = child:FindFirstChild("Config")
            if cfg and cfg:IsA("ModuleScript") then
                local ok, data = pcall(require, cfg)
                if ok and type(data) == "table" and data.Animations and data.DisplayName then
                    local a = data.Animations
                    if a.Idle or a.Walk or a.Run then
                        PlusAnimations[data.DisplayName] = { Idle = a.Idle, Walk = a.Walk, Run = a.Run }
                    end
                end
            end
        end
    end
    scan(Assets:FindFirstChild("Survivors"))
    scan(Assets:FindFirstChild("Killers"))
    local Skins = Assets:FindFirstChild("Skins")
    if Skins then
        for _, role in Skins:GetChildren() do
            for _, charFolder in role:GetChildren() do
                scan(charFolder)
            end
        end
    end
end)

local PlusAnimList = {}
for name in PlusAnimations do table.insert(PlusAnimList, name) end
table.sort(PlusAnimList)
table.insert(PlusAnimList, 1, "Original")

local PlusAnimState = {
    MoveConnection = nil,
    CurrentTracks = {},
    LastOriginal = nil
}

local function StopPlusAnimation()
    if PlusAnimState.MoveConnection then
        PlusAnimState.MoveConnection:Disconnect()
        PlusAnimState.MoveConnection = nil
    end
    for _, track in PlusAnimState.CurrentTracks do
        pcall(function() track:Stop() end)
    end
    PlusAnimState.CurrentTracks = {}
end

local function ApplyPlusAnimation()
    StopPlusAnimation()
    local selected = State.PlusAnimationChanger
    if not selected or selected == "Original" then return end
    local animData = PlusAnimations[selected]
    if not animData then return end
    if not LocalCharacter or not LocalHumanoid then return end
    local animator = LocalHumanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    local tracks = {}
    for _, key in { "Idle", "Walk", "Run" } do
        local id = animData[key]
        if id then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. tostring(id):gsub("%D", "")
            local track = animator:LoadAnimation(anim)
            track.Priority = Enum.AnimationPriority.Movement
            tracks[key] = track
        end
    end
    PlusAnimState.CurrentTracks = tracks
    PlusAnimState.MoveConnection = RunService.RenderStepped:Connect(function()
        if not LocalCharacter or not LocalCharacter.Parent then
            StopPlusAnimation()
            return
        end
        local current
        if LocalHumanoid.MoveDirection.Magnitude > 0.1 then
            if LocalHumanoid.WalkSpeed >= 20 then
                current = tracks.Run or tracks.Walk
            else
                current = tracks.Walk or tracks.Run
            end
        else
            current = tracks.Idle
        end
        for _, t in tracks do
            if t.IsPlaying and t ~= current then t:Stop() end
        end
        if current and not current:IsPlaying() then current:Play() end
    end)
end

table.insert(CharacterCallbacks, function()
    task.wait(0.5)
    if State.PlusAnimationChanger and State.PlusAnimationChanger ~= "Original" then
        ApplyPlusAnimation()
    end
end)

local function TogglePlusVoidRush(Enabled)
    local Assets = ReplicatedStorage:FindFirstChild("Assets")
    local Killers = Assets and Assets:FindFirstChild("Killers")
    local Noli = Killers and (Killers:FindFirstChild("Noli") or Killers:FindFirstChild("!Noli"))
    local Config = Noli and Noli:FindFirstChild("Config", true)
    if not Config then return end
    local ok, data = pcall(require, Config)
    if not ok or type(data) ~= "table" then return end
    local function findKey(t, name)
        for k, v in pairs(t) do
            if type(k) == "string" and k:find(name) and not k:find(name .. "OG") then
                return k, t
            end
            if type(v) == "table" then
                local k2, t2 = findKey(v, name)
                if k2 then return k2, t2 end
            end
        end
    end
    for _, entry in {
        { Name = "InitialTurnDuration", Value = 0.005, Default = 1.5 },
        { Name = "TurnSpeed", Value = 10000, Default = 1 },
        { Name = "InitialTurnMult", Value = 1000, Default = 6.6 }
    } do
        local key, parent = findKey(data, entry.Name)
        if key and parent then
            if Enabled then
                if parent[key .. "OG"] == nil then parent[key .. "OG"] = parent[key] end
                parent[key] = entry.Value
            else
                parent[key] = parent[key .. "OG"] or entry.Default
            end
        end
    end
end

local PlusHatchetCooldown = 0
local function GetPlusHatchetLevel(Character)
    if not Character then return 0 end
    local Resonance = ReplicatedStorage:FindFirstChild("Resonance", true)
    local ParticleHolder = Resonance and Resonance:FindFirstChild("ParticleHolder", true)
    if not ParticleHolder then return 0 end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return 0 end
    local Level = 0
    for _, Attachment in ParticleHolder:GetChildren() do
        if Attachment:IsA("Attachment") then
            local num = tonumber(Attachment.Name:match("%d+"))
            if num and num > Level then
                local Matches = true
                for _, Effect in Attachment:GetChildren() do
                    if not RootPart:FindFirstChild(Effect.Name) then
                        Matches = false
                        break
                    end
                end
                if Matches then Level = num end
            end
        end
    end
    return Level
end

task.spawn(function()
    while task.wait(0.1) do
        if State.PlusAutoHatchet and LocalCharacter and LocalHumanoid and LocalRoot then
            if LocalCharacter.Name:lower():find("jane") then
                local MainUI = PlayerGui:FindFirstChild("MainUI")
                local Container = MainUI and MainUI:FindFirstChild("AbilityContainer")
                if Container then
                    local Ability
                    for _, child in Container:GetChildren() do
                        if child.Name == "Hatchet" or child.Name == "Axe" then
                            Ability = child
                            break
                        end
                    end
                    if Ability then
                        local Killer, Distance = GetClosestKiller(State.PlusHatchetRange or 13)
                        if Killer and Distance and Distance <= (State.PlusHatchetRange or 13) then
                            local Level = GetPlusHatchetLevel(LocalCharacter)
                            if Level >= (State.PlusHatchetLevel or 2) then
                                local KillerRoot = Killer:FindFirstChild("HumanoidRootPart")
                                if KillerRoot and not KillerRoot:FindFirstChild("InvincibleFX") then
                                    if os.clock() - PlusHatchetCooldown > 1.6 then
                                        PlusHatchetCooldown = os.clock()
                                        pcall(function()
                                            if typeof(firesignal) == "function" and Ability.MouseButton1Click then
                                                firesignal(Ability.MouseButton1Down)
                                                firesignal(Ability.MouseButton1Click)
                                            else
                                                FireAbility("Hatchet")
                                            end
                                        end)
                                        task.spawn(function()
                                            local Timeout = os.clock() + 1
                                            while os.clock() < Timeout do
                                                if KillerRoot and LocalRoot then
                                                    local SelectedPosition = Vector3.new(KillerRoot.Position.X, LocalRoot.Position.Y, KillerRoot.Position.Z)
                                                    LocalRoot.CFrame = CFrame.new(LocalRoot.Position, SelectedPosition)
                                                end
                                                if LocalCharacter:GetAttribute("DisableShiftLockMovement") then
                                                    LocalRoot.AssemblyLinearVelocity = LocalRoot.CFrame.LookVector * 45
                                                end
                                                RunService.RenderStepped:Wait()
                                            end
                                            task.wait(1.6)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function ApplyPlusSpoofDevice(Value)
    if not Remote then return end
    if Value == "Original" then
        local InputDevices = { Keyboard = "PC", MouseButton1 = "PC", MouseButton2 = "PC", MouseMovement = "PC", Touch = "Mobile", Gamepad1 = "Console" }
        Value = InputDevices[UserInputService:GetLastInputType().Name] or "PC"
    elseif Value == "Nothing" then
        Value = nil
    end
    pcall(function()
        Remote:FireServer("SetDevice", { Value })
    end)
end

local PlusTimerConnection = nil
local function TogglePlusTimer(Enabled)
    if PlusTimerConnection then
        PlusTimerConnection:Disconnect()
        PlusTimerConnection = nil
    end
    if not Enabled then return end
    local TimerValue = ReplicatedStorage:FindFirstChild("RoundTimer")
    local RoundGui = PlayerGui:FindFirstChild("RoundTimer")
    local TimerUI = RoundGui and RoundGui:FindFirstChild("Time", true)
    if not TimerValue or not TimerUI then return end
    local function Format(Number)
        if not Number or type(Number) ~= "number" then return "0:00" end
        local m = math.floor(Number % 3600 / 60)
        local s = math.floor(Number % 60)
        return string.format("%d:%02d", m, s)
    end
    PlusTimerConnection = TimerValue:GetAttributeChangedSignal("TimeLeft"):Connect(function()
        if State.PlusCorrectTimer then
            pcall(function()
                TimerUI.Text = Format(TimerValue:GetAttribute("TimeLeft"))
            end)
        end
    end)
    pcall(function()
        TimerUI.Text = Format(TimerValue:GetAttribute("TimeLeft"))
    end)
end

local PlusUnderground = {
    Active = false,
    Hooking = false
}

local function PlusIsHitboxNotNear(HitboxPart, Position)
    if not HitboxPart or not Position or not LocalRoot then return false end
    local Params = OverlapParams.new()
    Params.FilterType = Enum.RaycastFilterType.Include
    Params.MaxParts = 1
    Params.FilterDescendantsInstances = { HitboxPart }
    local Res = workspace:GetPartBoundsInRadius(Position, 2.5, Params)
    return #Res == 0
end

local function PlusVelocityToPosition(target)
    if not LocalRoot or not LocalCharacter then return end
    local TimeLimit = workspace.DistributedGameTime + 7
    local OGCG = LocalRoot.CollisionGroup
    local AllParts = LocalCharacter:QueryDescendants("BasePart")
    for _, v in AllParts do v.CollisionGroup = "None" end
    local Body = Instance.new("BodyVelocity")
    Body.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Body.Velocity = Vector3.zero
    Body.Parent = LocalRoot
    while (LocalRoot.Position - target).Magnitude > 2 and not (workspace.DistributedGameTime >= TimeLimit) do
        Body.Velocity = (target - LocalRoot.Position).Unit * 100
        RunService.RenderStepped:Wait()
    end
    Body:Destroy()
    for _, v in AllParts do v.CollisionGroup = OGCG end
end

local function PlusGoUnder(Value)
    if not Value then PlusUnderground.Active = false; return end
    if PlusUnderground.Active then return end
    if not LocalRoot or not LocalHumanoid then return end
    local LocalHead = LocalCharacter and LocalCharacter:FindFirstChild("Head")
    if not LocalHead then return end
    local OldCFrame = LocalRoot.CFrame
    local UnderCFrame = OldCFrame * CFrame.new(0, -22, 0)
    LocalHumanoid.CameraOffset = Vector3.new(0, 12e12, 0)
    task.wait(0.1)
    LocalRoot.CFrame = UnderCFrame
    local Tries = 0
    local TimerStop = workspace.DistributedGameTime + 3.5
    repeat
        Tries += 1
        LocalRoot.Velocity = Vector3.zero
        PlusVelocityToPosition(UnderCFrame.Position)
        LocalHead.Anchored = true
        repeat task.wait() until PlusIsHitboxNotNear(LocalCharacter:FindFirstChild("QueryHitbox"), OldCFrame.Position) or not LocalRoot or not LocalCharacter or TimerStop < workspace.DistributedGameTime
        PlusUnderground.Active = true
        task.wait()
        LocalRoot.Velocity = Vector3.zero
        LocalHead.Anchored = false
        LocalRoot.CFrame = OldCFrame
        RunService.Heartbeat:Wait()
        LocalRoot.Velocity = Vector3.zero
    until PlusIsHitboxNotNear(LocalCharacter:FindFirstChild("QueryHitbox"), OldCFrame.Position) or Tries >= 3
    if Tries >= 3 then
        PlusUnderground.Active = false
        State.PlusInvincible = false
    end
end

local function TogglePlusInvincible(Enabled)
    if Enabled then
        pcall(function()
            if not PlusUnderground.Hooking and typeof(hookmetamethod) == "function" then
                PlusUnderground.Hooking = true
                local Unreliable = NetworkFolder and NetworkFolder:FindFirstChild("UnreliableRemoteEvent")
                local newcclosure = typeof(newcclosure) == "function" and newcclosure or new_cclosure
                local checkcaller = typeof(checkcaller) == "function" and checkcaller or check_caller
                if Unreliable and newcclosure and checkcaller and typeof(getnamecallmethod) == "function" then
                    local __namecall
                    __namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                        if not checkcaller() and PlusUnderground.Active and getnamecallmethod() == "FireServer" and self == Unreliable and State.PlusInvincible then
                            local args = { ... }
                            if args[1] == math.pow(#"invalidnumber", 0) then
                                return function() return nil end
                            end
                        end
                        return __namecall(self, ...)
                    end))
                end
            end
        end)
        task.spawn(PlusGoUnder, true)
    else
        PlusUnderground.Active = false
        if LocalHumanoid then pcall(function() LocalHumanoid.CameraOffset = Vector3.zero end) end
    end
end

table.insert(CharacterCallbacks, function()
    task.wait(1)
    if State.PlusInvincible then
        task.spawn(TogglePlusInvincible, true)
    end
end)

local Tabs = {}

local function CreateTab(Title, Icon)
    local Tab
    pcall(function()
        Tab = Window:Tab({ Title = Title, Icon = Icon })
    end)
    return Tab
end

local TabList = {
    { "Info", "Info Script", "info" },
    { "Main", "Auto Block", "shield" },
    { "TwoTime", "Two Time", "swords" },
    { "Generators", "Generators", "cpu" },
    { "Chance", "Chance", "coins" },
    { "Visuals", "Visuals", "eye" },
    { "Player", "Player", "user" },
    { "Automation", "Automation", "cpu" },
    { "Items", "Items", "backpack" },
    { "Features", "Features", "wrench" },
    { "Abilities", "Abilities", "swords" },
    { "Action", "Action", "smile" },
    { "Music", "Music", "music" },
    { "Misc", "Misc", "paperclip" },
    { "Extras", "Extras", "settings" },
    { "Configs", "Configs", "save" }
}

for _, Data in TabList do
    Tabs[Data[1]] = CreateTab(Data[2], Data[3])
    if not Tabs[Data[1]] then return warn("Failed to create the tab " .. Data[2]) end
end

local Elements = {}

local BubbleGui
local BubbleToken = 0
local BubbleConnections = {}

local function SetAutoBlockState(Value)
    State.AutoBlock = Value
    SetAutoBlock(Value)
    pcall(function()
        if Elements.AutoBlock then Elements.AutoBlock:Set(Value) end
    end)
end

local function SetFloatingButton(Enabled)
    BubbleToken += 1
    for _, Connection in BubbleConnections do Connection:Disconnect() end
    table.clear(BubbleConnections)
    if BubbleGui then
        BubbleGui:Destroy()
        BubbleGui = nil
    end
    if not Enabled then return end
    local Token = BubbleToken
    local OnColor = Color3.fromRGB(40, 200, 70)
    local OffColor = Color3.fromRGB(220, 40, 40)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AutoBlockBubble"
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 100
    Gui.Parent = PlayerGui
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 46, 0, 46)
    Button.Position = UDim2.new(0, 20, 0.5, 0)
    Button.BackgroundColor3 = State.AutoBlock and OnColor or OffColor
    Button.AutoButtonColor = false
    Button.BorderSizePixel = 0
    Button.Text = "AB"
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 16
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Parent = Gui
    Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.5
    Stroke.Thickness = 1.5
    Stroke.Parent = Button
    BubbleGui = Gui
    local Dragging = false
    local Moved = false
    local DragInput
    local DragStart
    local StartPosition
    table.insert(BubbleConnections, Button.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Moved = false
            DragInput = Input
            DragStart = Input.Position
            StartPosition = Button.Position
        end
    end))
    table.insert(BubbleConnections, UserInputService.InputChanged:Connect(function(Input)
        if not Dragging then return end
        if Input == DragInput or Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            if Delta.Magnitude > 8 then Moved = true end
            if Moved then
                Button.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
            end
        end
    end))
    table.insert(BubbleConnections, UserInputService.InputEnded:Connect(function(Input)
        if not Dragging then return end
        if Input == DragInput or Input == Enum.UserInputType.MouseButton1 then
            Dragging = false
            if not Moved then
                SetAutoBlockState(not State.AutoBlock)
                Button.BackgroundColor3 = State.AutoBlock and OnColor or OffColor
            end
        end
    end))
    task.spawn(function()
        while Token == BubbleToken and Gui.Parent do
            local Target = State.AutoBlock and OnColor or OffColor
            if Button.BackgroundColor3 ~= Target then Button.BackgroundColor3 = Target end
            task.wait(0.1)
        end
    end)
end

AddSection(Tabs.Info, "FluxSaken")

pcall(function()
    Tabs.Info:Paragraph({
        Title = "FluxSaken",
        Desc = "By Pichigdasos",
        Image = LogoId,
        ImageSize = 160
    })
end)

AddButton(Tabs.Info, "Copy Discord Server", function()
    if CopyText(DiscordLink) then
        Notify("Discord", "Discord link copied", 3)
    else
        Notify("Discord", DiscordLink, 8)
    end
end)

AddSection(Tabs.Main, "Main")

Elements.AutoBlock = AddToggle(Tabs.Main, "AutoBlock", "Auto Block", false, SetAutoBlock)
AddToggle(Tabs.Main, "FloatingButton", "Floating Auto Block Button", false, SetFloatingButton)
AddSlider(Tabs.Main, "BlockDelay", "Auto Block Delay", 0, 300, 0, 10)
AddSlider(Tabs.Main, "BlockRange", "Range", 5, 60, 5, 1)

AddToggle(Tabs.Main, "HitboxDrag", "Hitbox Drag", false)
AddSlider(Tabs.Main, "DragSpeed", "Hitbox Drag Speed", 2, 30, 14, 1)

AddSection(Tabs.Main, "Legit")

AddToggle(Tabs.Main, "VisualCheck", "Visual Check", false)
AddToggle(Tabs.Main, "StrictVisualCheck", "Strict Visual Check", false)
AddToggle(Tabs.Main, "WallCheck", "Wall Check", false)

AddSection(Tabs.TwoTime, "Two Time")

AddToggle(Tabs.TwoTime, "BackstabEnabled", "Backstab", false)
AddSlider(Tabs.TwoTime, "TTStartDelay", "Start Delay", 0, 1, 0.05, 0.01)
AddSlider(Tabs.TwoTime, "TTDuration", "Duration", 0.05, 1, 0.2, 0.05)
AddSlider(Tabs.TwoTime, "TTBehindStuds", "Behind Studs", 1, 10, 4, 0.5)
AddToggle(Tabs.TwoTime, "TTDistCheck", "Distance Check", false)
AddSlider(Tabs.TwoTime, "TTDistCheckStud", "Stud Distance", 1, 30, 7, 0.5)
AddToggle(Tabs.TwoTime, "TTAutoStuds", "Auto Studs", false)
AddSlider(Tabs.TwoTime, "TTAutoStandStuds", "Behind Studs When Standing", 1, 15, 5.5, 0.5)
AddSlider(Tabs.TwoTime, "TTAutoRunStuds", "Behind Studs When Running", 1, 15, 3.4, 0.5)
AddToggle(Tabs.TwoTime, "TTDetectPing", "Also Detect Ping", false)
AddToggle(Tabs.TwoTime, "TTMoreDirect", "More Direct", false)
AddToggle(Tabs.TwoTime, "TTDashstab", "Dashstab", false)
AddSlider(Tabs.TwoTime, "TTDSStartDelay", "DS Start Delay", 0, 1, 0.1, 0.01)

AddSection(Tabs.Generators, "Auto Generator")

AddToggle(Tabs.Generators, "AutoGeneratorMinigame", "Auto Generator", false, function(Value)
    MinigameSolver.Enabled = Value
    MinigameSolver.Generation = MinigameSolver.Generation + 1
    pcall(installMinigameHooks)
end)
AddSlider(Tabs.Generators, "MinGameStartDelay", "Start Delay", 0, 5, 1.5, 0.1)
AddSlider(Tabs.Generators, "FlowCellSpeed", "Flow Cell Speed (ms)", 0, 250, 50, 1)
AddSlider(Tabs.Generators, "ConnectPairDelay", "Connect Pair Delay (ms)", 100, 3000, 1000, 10)
AddSlider(Tabs.Generators, "GearTurnSpeed", "Gear Turn Speed (ms)", 0, 150, 30, 1)

AddSection(Tabs.Chance, "Chance")

AddToggle(Tabs.Chance, "ChanceAim", "Auto Aim", false)
AddInput(Tabs.Chance, "ChancePrediction", "Prediction", "4")
AddToggle(Tabs.Chance, "ChanceCoinFlip", "Auto CoinFlip", false, Feature.SetChanceCoinFlip)

AddSection(Tabs.Visuals, "ESP")

AddToggle(Tabs.Visuals, "KillerEsp", "Killer ESP", false)
AddToggle(Tabs.Visuals, "SurvivorEsp", "Survivor ESP", false)
AddToggle(Tabs.Visuals, "GeneratorEsp", "Generator ESP", false)
AddToggle(Tabs.Visuals, "ItemEsp", "Item ESP", false)
AddToggle(Tabs.Visuals, "EspNames", "ESP Names", false)
AddToggle(Tabs.Visuals, "EspHealth", "ESP Health", false)
AddToggle(Tabs.Visuals, "KillerSkin", "Show Killer Skin", false)
AddToggle(Tabs.Visuals, "SurvivorSkin", "Show Survivor Skin", false)
AddToggle(Tabs.Visuals, "LimitEsp", "Limit ESP Distance", false)
AddSlider(Tabs.Visuals, "EspMaxDistance", "ESP Max Distance", 10, 1000, 10, 10)

AddSection(Tabs.Visuals, "More ESP")

AddToggle(Tabs.Visuals, "PizzaEsp", "Pizza ESP", false)
AddToggle(Tabs.Visuals, "TripwireEsp", "Tripwire ESP", false)
AddToggle(Tabs.Visuals, "MineEsp", "Mine ESP", false)
AddToggle(Tabs.Visuals, "RespawnEsp", "Respawn ESP", false)
AddToggle(Tabs.Visuals, "GraffitiEsp", "Graffiti ESP", false)
AddToggle(Tabs.Visuals, "DeliveryEsp", "Pizza Delivery ESP", false)
AddToggle(Tabs.Visuals, "ZombieEsp", "Zombie ESP", false)
AddToggle(Tabs.Visuals, "BulbEsp", "GroundBulb ESP", false)
AddToggle(Tabs.Visuals, "VineEsp", "Vine ESP", false)

AddSection(Tabs.Visuals, "Tracers")

AddToggle(Tabs.Visuals, "KillerTracers", "Killer Tracers", false)
AddToggle(Tabs.Visuals, "SurvivorTracers", "Survivor Tracers", false)
AddToggle(Tabs.Visuals, "GeneratorTracers", "Generator Tracers", false)
AddToggle(Tabs.Visuals, "ItemTracers", "Item Tracers", false)
AddToggle(Tabs.Visuals, "PizzaTracers", "Pizza Tracers", false)
AddToggle(Tabs.Visuals, "DeliveryTracers", "Pizza Delivery Tracers", false)
AddToggle(Tabs.Visuals, "ZombieTracers", "Zombie Tracers", false)
AddToggle(Tabs.Visuals, "TripwireTracers", "Tripwire Tracers", false)
AddToggle(Tabs.Visuals, "MineTracers", "Mine Tracers", false)
AddToggle(Tabs.Visuals, "RespawnTracers", "Respawn Tracers", false)

AddSection(Tabs.Visuals, "Camera")

AddToggle(Tabs.Visuals, "HideInjury", "Hide Injured UI", false, ApplyInjury)
AddToggle(Tabs.Visuals, "DisableBlindness", "Disable Blindness", false, ApplyBlindness)
AddToggle(Tabs.Visuals, "FreeZoom", "Free Zoom", false, SetFreeZoom)
AddToggle(Tabs.Visuals, "CameraNoclip", "Camera Noclip", false, SetCameraNoclip)
AddToggle(Tabs.Visuals, "EnableFov", "Enable FOV", false, SetFov)
AddSlider(Tabs.Visuals, "FovValue", "FOV Value", 70, 120, 70, 1)

AddSection(Tabs.Visuals, "World")

AddToggle(Tabs.Visuals, "Fullbright", "Fullbright", false, SetFullbright)
AddToggle(Tabs.Visuals, "NoShadows", "No Shadows", false, Feature.SetNoShadows)
AddToggle(Tabs.Visuals, "NoFog", "No Fog", false, Feature.SetNoFog)
AddToggle(Tabs.Visuals, "DeleteRagdolls", "Delete Ragdolls", false, SetDeleteRagdolls)

AddSection(Tabs.Player, "Stamina")

AddToggle(Tabs.Player, "InfiniteStamina", "Infinite Stamina", false, SetInfiniteStamina)
AddToggle(Tabs.Player, "ModifyMaxStamina", "Modify Max Stamina", false, Feature.StaminaToggle("MaxStamina"))
AddSlider(Tabs.Player, "MaxStaminaValue", "Max Stamina", 1, 500, 100, 1)
AddToggle(Tabs.Player, "ModifyStaminaGain", "Modify Stamina Gain", false, Feature.StaminaToggle("StaminaGain"))
AddSlider(Tabs.Player, "StaminaGainValue", "Stamina Gain", 0, 120, 25, 1)
AddToggle(Tabs.Player, "ModifyStaminaLoss", "Modify Stamina Loss", false, Feature.StaminaToggle("StaminaLoss"))
AddSlider(Tabs.Player, "StaminaLossValue", "Stamina Loss", 0, 100, 10, 1)
AddToggle(Tabs.Player, "ModifySprintSpeed", "Modify Sprint Speed", false, Feature.StaminaToggle("SprintSpeed"))
AddSlider(Tabs.Player, "SprintSpeedValue", "Sprint Speed", 1, 60, 28, 1)

AddSection(Tabs.Player, "Character")

AddToggle(Tabs.Player, "AntiSlowness", "Anti Slowness", false, SetAntiSlowness)
AddToggle(Tabs.Player, "EnableJumping", "Enable Jumping", false, ApplyJumping)
AddToggle(Tabs.Player, "PlusInvincible", "Invincible", false, TogglePlusInvincible)

AddSection(Tabs.Player, "Movement")

AddToggle(Tabs.Player, "SpeedBoost", "Speed Boost", false, SetSpeedBoost)
AddSlider(Tabs.Player, "SpeedValue", "Speed Value", 1, 500, 1, 1)
AddToggle(Tabs.Player, "Flight", "Flight", false, SetFlight)
AddSlider(Tabs.Player, "FlightSpeed", "Flight Speed", 1, 200, 1, 1)

AddSection(Tabs.Automation, "Automation")

AddToggle(Tabs.Automation, "AutoEscape", "Auto Escape", false)
AddSlider(Tabs.Automation, "EscapeCooldown", "Escape Cooldown", 0.2, 1.2, 0.2, 0.1)
AddToggle(Tabs.Automation, "AutoDisarm", "Auto Disarm", false, SetAutoDisarm)

AddSection(Tabs.Items, "Items")

AddToggle(Tabs.Items, "AutoPickup", "Auto Pickup", false)
AddButton(Tabs.Items, "TP MedKit", function()
    TPToItem("MedKit")
end)
AddButton(Tabs.Items, "TP BloxyCola", function()
    TPToItem("BloxyCola")
end)

AddSection(Tabs.Features, "Killers")

AddToggle(Tabs.Features, "DeleteFakeNoli", "Delete Fake Noli", false)
AddToggle(Tabs.Features, "DisableNoliNPC", "Disable Noli's NPC", false, HandleNoliNPC)
AddToggle(Tabs.Features, "Disable007n7NPC", "Disable 007n7's NPC", false, Handle007n7NPC)
AddToggle(Tabs.Features, "DisableTrails", "Disable John Doe's Trails", false, ApplyInGameObjects)
AddToggle(Tabs.Features, "DisableFootprints", "Disable John Doe's Footprints", false, ApplyInGameObjects)
AddToggle(Tabs.Features, "SmallSpikes", "Smaller Spike Collisions", false, ApplyInGameObjects)
AddToggle(Tabs.Features, "DisableKillerWalls", "Disable Killer Walls", false, SetKillerWalls)

AddSection(Tabs.Features, "Killer Tools")

AddToggle(Tabs.Features, "DashTurn", "c00lkidd Dash Turn", false, Feature.SetDashTurn)
AddToggle(Tabs.Features, "AutoBreakFree", "Auto Break Free", false)
AddToggle(Tabs.Features, "AutoPullRope", "Auto Pull Rope", false)
AddToggle(Tabs.Features, "AzureQte", "Auto Azure QTE", false, Feature.SetAzureQte)
AddToggle(Tabs.Features, "PlusBetterVoidRush", "Better Void Rush", false, TogglePlusVoidRush)

AddSection(Tabs.Abilities, "Sk8")

AddToggle(Tabs.Abilities, "AutoTrick", "Auto Trick", false, Feature.SetAutoTrick)
AddToggle(Tabs.Abilities, "Sk8Control", "Enable SK8 Control", false)
AddToggle(Tabs.Abilities, "FastSpray", "Enable Fast Spray", false)
AddSlider(Tabs.Abilities, "SpraySpeed", "Spray Speed", 0.5, 10, 0.5, 0.5)

AddSection(Tabs.Abilities, "Combat")

AddToggle(Tabs.Abilities, "PlusAutoHatchet", "Auto Hatchet (Jane Doe)", false)
AddSlider(Tabs.Abilities, "PlusHatchetLevel", "Auto Hatchet Level Threshold", 0, 3, 2, 1)
AddSlider(Tabs.Abilities, "PlusHatchetRange", "Auto Hatchet Range", 5, 25, 13, 1)

AddSection(Tabs.Action, "Emotes")

AddDropdown(Tabs.Action, "EmoteSelect", "Select Emote", Feature.EmoteNames, Feature.EmoteNames[1])
AddButton(Tabs.Action, "Play Emote", Feature.PlayEmote)
AddButton(Tabs.Action, "Stop Emote", Feature.StopEmote)

AddSection(Tabs.Action, "Animations")

local AnimDropdown = AddDropdown(Tabs.Action, "AnimSelect", "Select Animation", Feature.AnimNames, Feature.AnimNames[1])
AddButton(Tabs.Action, "Apply Animation", Feature.ApplyAnimation)
AddButton(Tabs.Action, "Stop Animation", Feature.StopAnimation)
AddButton(Tabs.Action, "Refresh Animation List", function()
    local Names = Feature.RefreshAnimations()
    pcall(function() AnimDropdown:Refresh(Names) end)
    Notify("Animations", "List refreshed", 3)
end)

AddSection(Tabs.Action, "Animation Changer")

AddDropdown(Tabs.Action, "PlusAnimationChanger", "Animation Changer", PlusAnimList, "Original", function()
    ApplyPlusAnimation()
end)
AddToggle(Tabs.Action, "PlusChangeInLobby", "Change In Lobby", false)

AddSection(Tabs.Music, "LMS Music")

AddToggle(Tabs.Music, "LmsOn", "Apply LMS", false, Feature.SetLms)
AddDropdown(Tabs.Music, "LmsTrack", "LMS Track", Feature.MusicNames, Feature.MusicNames[1])
AddButton(Tabs.Music, "Preload LMS", Feature.PreloadMusic)
AddButton(Tabs.Music, "Preview", Feature.StartPreview)
AddButton(Tabs.Music, "Stop Preview", Feature.StopPreview)

AddSection(Tabs.Misc, "Misc")

AddToggle(Tabs.Misc, "AntiHiddenStats", "Anti Hidden Stats", false, SetAntiHiddenStats)
AddToggle(Tabs.Misc, "ShowChat", "Show Chat", false, SetShowChat)
AddButton(Tabs.Misc, "Rejoin", RejoinServer)

AddSection(Tabs.Misc, "Device")

AddDropdown(Tabs.Misc, "PlusSpoofDevice", "Spoof Device", { "Original", "PC", "Mobile", "Console", "Nothing" }, "Original", ApplyPlusSpoofDevice)
AddToggle(Tabs.Misc, "PlusCorrectTimer", "Always Display Correct Timer", false, TogglePlusTimer)

AddSection(Tabs.Extras, "Punch")

AddToggle(Tabs.Extras, "PunchAimbot", "Punch Aimbot", false)

if HasAsset(SurvivorAssets, "Guest1337") or not SurvivorAssets then
    AddToggle(Tabs.Extras, "AutoPunch", "Guest1337 Auto Punch", false)
end

AddSection(Tabs.Extras, "Display")

AddToggle(Tabs.Extras, "ShowPing", "Show Ping", false, SetShowPing)

AddSection(Tabs.Configs, "Configs")

local ConfigOutput
local PendingConfigId = ""

pcall(function()
    ConfigOutput = Tabs.Configs:Input({
        Title = "Your Config ID",
        Value = "",
        Placeholder = "Press Create Current Config ID",
        Callback = function() end
    })
end)

AddButton(Tabs.Configs, "Create Current Config ID", function()
    local Id, Copied = Feature.CreateConfigId()
    local Shown = pcall(function() ConfigOutput:Set(Id) end)
    if not Shown then
        pcall(function()
            Tabs.Configs:Paragraph({ Title = "Your Config ID", Desc = Id })
        end)
    end
    if Copied then
        Notify("Configs", "Config ID created and copied", 4)
    else
        Notify("Configs", "Config ID created, copy it from the box", 5)
    end
end)

pcall(function()
    Tabs.Configs:Input({
        Title = "Enter Config ID",
        Value = "",
        Placeholder = "Config ID",
        Callback = function(Text) PendingConfigId = Text end
    })
end)

AddButton(Tabs.Configs, "Load", function()
    if Feature.LoadConfig(PendingConfigId) then
        Notify("Configs", "Configuration loaded", 4)
    else
        Notify("Configs", "Invalid config ID", 4)
    end
end)

Feature.AfterLoad = function() end

if not OfficialGame then
    Notify("Warning", "This is not the official game, some features may not work", 6)
end

task.spawn(OnCharacter, LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

Notify("FluxSaken", "Loaded successfully", 5)
