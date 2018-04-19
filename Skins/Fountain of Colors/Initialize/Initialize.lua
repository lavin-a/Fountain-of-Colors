function Initialize()
  config = SKIN:GetVariable("Config")
  includeVariables = 0

  -- Measure/meter options should be absolute (not referenced or calculated by the skin parser)
  SKIN:Bang("!WriteKeyValue", "Audio", "Port", SKIN:GetVariable("Port"), "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "ID", SKIN:GetVariable("ID"), "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "FFTSize", SKIN:ParseFormula(SKIN:GetVariable("FFTSize")), "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "FFTOverlap", SKIN:ParseFormula(SKIN:GetVariable("FFTOverlap")), "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "FFTAttack", SKIN:ParseFormula(SKIN:GetVariable("FFTAttack")) ~= 300 and SKIN:ParseFormula(SKIN:GetVariable("FFTAttack")) or '', "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "FFTDecay", SKIN:ParseFormula(SKIN:GetVariable("FFTDecay")) ~= 300 and SKIN:ParseFormula(SKIN:GetVariable("FFTDecay")) or '', "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "Bands", math.max(2, SKIN:ParseFormula(SKIN:GetVariable("Bands"))), "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "FreqMin", SKIN:ParseFormula(SKIN:GetVariable("FreqMin")) ~= 20 and SKIN:ParseFormula(SKIN:GetVariable("FreqMin")) or '', "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "FreqMax", SKIN:ParseFormula(SKIN:GetVariable("FreqMax")) ~= 20000 and SKIN:ParseFormula(SKIN:GetVariable("FreqMax")) or '', "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Audio", "Sensitivity", SKIN:ParseFormula(SKIN:GetVariable("Sensitivity")) ~= 35 and SKIN:ParseFormula(SKIN:GetVariable("Sensitivity")) or '', "#@##SkinGroup#.inc")

  -- Conditional inclusion of measures/meters
  if SKIN:ParseFormula(SKIN:GetVariable("Angle")) ~= 0 then
    includeVariables = 1
    SKIN:Bang("!WriteKeyValue", "Include", "@Include2", "#*@*#SkinRotation.inc", "#@##SkinGroup#.inc")
  else
    SKIN:Bang("!WriteKeyValue", "Include", "@Include2", "", "#@##SkinGroup#.inc")
  end
  
  if SKIN:GetVariable("Colors") ~= "Individual" then
    SKIN:Bang("!WriteKeyValue", "Include", "@Include3", "", "#@##SkinGroup#.inc")
  else
    SKIN:Bang("!WriteKeyValue", "Include", "@Include3", "#*@*#IndividualBarColors.inc", "#@##SkinGroup#.inc")
  end
  
  if SKIN:GetVariable("Colors") ~= "Single" and true or (SKIN:ParseFormula(SKIN:GetVariable("DecayEffect")) ~= 0 and true or false) then
    includeVariables = 1
    SKIN:Bang("!WriteKeyValue", "Include", "@Include4", "#*@*#ColorChanger.inc", "#@##SkinGroup#.inc")
    -- Also let ColorChanger know which skins are active
    SKIN:Bang("!WriteKeyValue", "Variables", "SetCloneColorState", '[!CommandMeasure ScriptColorChanger """AddChild("[CurrentConfig]", #Invert#)""" "#ROOTCONFIG#"]', "#@#Variables.inc")
	
	if SKIN:GetVariable("Config") == SKIN:GetVariable("ROOTCONFIG") then
	  mainColorState = '[!CommandMeasure ScriptColorChanger SetParent() "#ROOTCONFIG#"]'
	else mainColorState = "" end
  else
    mainColorState = ""
    SKIN:Bang("!WriteKeyValue", "Include", "@Include4", "", "#@##SkinGroup#.inc")
    SKIN:Bang("!WriteKeyValue", "Variables", "SetCloneColorState", "", "#@#Variables.inc")
  end
  
  nearestAxis, matrix = 0, ""
  SKIN:Bang("!WriteKeyValue", "NearestAxis", "OnUpdateAction", '[!CommandMeasure ScriptInitialize "nearestAxis = [NearestAxis]" "#ROOTCONFIG#\\Initialize"]', "#@#SkinRotation.inc")
  SKIN:Bang("!WriteKeyValue", "Matrix", "OnUpdateAction", '[!CommandMeasure ScriptInitialize """matrix = "[Matrix]"""" "#ROOTCONFIG#\\Initialize"]', "#@#SkinRotation.inc")
  
  if includeVariables ~= 0 then
    SKIN:Bang("!WriteKeyValue", "Rainmeter", "@Include", "#*@*#Variables.inc", "#ROOTCONFIGPATH#Fountain of Colors.ini")
  else
    SKIN:Bang("!WriteKeyValue", "Rainmeter", "@Include", "", "#ROOTCONFIGPATH#Fountain of Colors.ini")
  end
  
  SKIN:Bang("!WriteKeyValue", "Rainmeter", "ContextAction", '[!ActivateConfig "#ROOTCONFIG#\\Options"]', "#@##SkinGroup#.inc")
  SKIN:Bang("!WriteKeyValue", "Rainmeter", "OnRefreshAction", "", "#@##SkinGroup#.inc")
  
  SKIN:Bang("!DeactivateConfig", config)
  SKIN:Bang("!ActivateConfig", config)
  

  SKIN:Bang(mainColorState)

  -- Set options on measures/meters for the current skin

  local barHeight = SKIN:ParseFormula(SKIN:GetVariable("BarHeight"))
  local barWidth, barGap = SKIN:ParseFormula(SKIN:GetVariable("BarWidth")), SKIN:ParseFormula(SKIN:GetVariable("BarGap"))
  local offset = barWidth + barGap
  local angle = SKIN:ParseFormula(SKIN:GetVariable("Angle"))
  local meterName, measureName = {}, {}
  local lowerLimit, upperLimit = SKIN:ParseFormula(SKIN:GetVariable("FirstBandIndex")) + 1, math.max(2, (SKIN:ParseFormula(SKIN:GetVariable("Bands"))-1) + 1)
  
  for i = lowerLimit, upperLimit do
    meterName[i] = i-1
  
    if nearestAxis ~= 0 then
      SKIN:Bang("!SetOption", meterName[i], "W", barHeight, config)
      SKIN:Bang("!SetOption", meterName[i], "H", barWidth, config)
      SKIN:Bang("!SetOption", meterName[i], "Y", offset * (i - lowerLimit), config)
    else
      SKIN:Bang("!SetOption", meterName[i], "W", barWidth, config)
      SKIN:Bang("!SetOption", meterName[i], "H", barHeight, config)
      SKIN:Bang("!SetOption", meterName[i], "X", offset * (i - lowerLimit), config)
    end
  
    if angle ~= 0 then
      if nearestAxis ~= 0 then
        SKIN:Bang("!SetOption", meterName[i], "BarOrientation", "Horizontal", config)
      end
      SKIN:Bang("!SetOption", meterName[i], "AntiAlias", 1, config)
      SKIN:Bang("!SetOption", meterName[i], "TransformationMatrix", matrix, config)
      SKIN:Bang("!UpdateMeter", meterName[i], config)
      SKIN:Bang("!SetOption", meterName[i], "TransformationMatrix", "", config)
    end
  
    if SKIN:GetVariable("Colors") == "Single" then
      SKIN:Bang("!SetOption", meterName[i], "BarColor", SKIN:GetVariable("PaletteColor1"), config)
    end
    SKIN:Bang("!SetOption", meterName[i], "UpdateDivider", 0, config)
    SKIN:Bang("!UpdateMeter", meterName[i], config)


    measureName[i] = "Audio"..i-1

    if SKIN:GetVariable("Channel") ~= "Avg" then
      SKIN:Bang("!SetOption", measureName[i], "Channel", SKIN:GetVariable("Channel"), config)
    end
    SKIN:Bang("!SetOption", measureName[i], "AverageSize", SKIN:ParseFormula(SKIN:GetVariable("AverageSize")), config)
    SKIN:Bang("!SetOption", measureName[i], "UpdateDivider", 0, config)
    SKIN:Bang("!UpdateMeasure", measureName[i], config)
  end
  
  if SKIN:GetVariable("Colors") == "Wallpaper" then SKIN:Bang("!CommandMeasure", "MeasureRun", "Run", config) end

  SKIN:Bang("!WriteKeyValue", "NearestAxis", "OnUpdateAction", "", "#@#SkinRotation.inc")
  SKIN:Bang("!WriteKeyValue", "Matrix", "OnUpdateAction", "", "#@#SkinRotation.inc")
  
  -- Each skin .INI file has some specific settings to be copied to the Variables.inc file for easier retrieval
  local envAngle = '[!WriteKeyValue Variables Angle #*Angle*# "#*@*#Variables.inc"]'
  local envInvert = '[!WriteKeyValue Variables Invert #*Invert*# "#*@*#Variables.inc"]'
  local envChannel = '[!WriteKeyValue Variables Channel #*Channel*# "#*@*#Variables.inc"]'
  local envPort = '[!WriteKeyValue Variables Port #*Port*# "#*@*#Variables.inc"]'
  local envConfig = '[!WriteKeyValue Variables Config "#*CURRENTCONFIG*#" "#*@*#Variables.inc"]'

  -- For the next skin initialization
  local envVariables = envAngle .. envInvert .. envChannel .. envPort .. envConfig
  local envInitialize = envVariables .. '[!ActivateConfig "#*ROOTCONFIG*#\\Initialize"]'
  SKIN:Bang("!WriteKeyValue", "Rainmeter", "OnRefreshAction", envInitialize, "#@##SkinGroup#.inc")
  
  SKIN:Bang("!DeactivateConfig")
end