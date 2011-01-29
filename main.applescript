-- main.applescript
-- Regex Finder Items

--  Created by Annard Brouwer on 27/10/2010.
--  Copyright (c) 2010 Let Software Dream Ltd., All Rights Reserved.

property NameAttributeIdx : 0
property CommentAttributeIdx : 1
property dupFNErr : -48
property paramErr : -50
property userCanceledErr : -128

on run {input, parameters}
	local findText, shouldReplace, replaceText, useRegExp, simulate, aPath
	
	set output to {}
	
	set findText to (|findText| of parameters)
	set replaceText to (|replaceText| of parameters)
	-- Note that some strange hackery is necessary because the values returned at runtime
	-- by the bindings are different between Automator and the different runners (Services etc.)!
	set useRegExp to (|useRegExp| of parameters)
	if (class of useRegExp) is integer then set useRegExp to (useRegExp = 1)
	set shouldReplace to (|shouldReplace| of parameters)
	if (class of shouldReplace) is integer then set shouldReplace to (shouldReplace = 1)
	set simulate to (simulation of parameters)
	if (class of simulate) is integer then set simulate to (simulate = 1)
	
	-- check regexp beforehand
	if useRegExp then
		local strVal
		
		set strVal to call method "validateRegularExpression:" of class "RFIRegexMediator" with parameters {findText}
		if (strVal ≠ "OK") then
			error strVal number paramErr
		end if
	end if
	
	-- process input
	try
		repeat with aPath in input
			local oldName, newName
			
			-- aPath is an alias (see Info.plist)
			tell application id "com.apple.Finder"
				set oldName to the name of aPath
			end tell
			if shouldReplace then
				set newName to call method "find:replace:inText:useRegEx:" of class "RFIRegexMediator" with parameters {findText, replaceText, oldName, useRegExp}
				if newName ≠ missing value then
					if not simulate then
						my renameFileTo(aPath, newName)
						set output to output & aPath
					else
						set output to output & newName
					end if
				end if
			else
				local isMatch
				
				if useRegExp then
					set isMatch to call method "regularExpression:isMatchedByString:" of class "RFIRegexMediator" with parameters {findText, oldName}
				else
					considering case
						set isMatch to (oldName = findText)
					end considering
				end if
				if isMatch then set output to output & aPath
			end if
		end repeat
	on error errMsg number errNo
		if the errNo is not userCanceledErr then log "ERROR: (Regex Finder Items) " & errMsg & " [" & errNo & "]"
		error errMsg number errNo
	end try
	
	return output
end run

on pathExists(thePath)
	try
		set thePath to thePath as alias
	on error
		return false
	end try
	return true
end pathExists

on renameFileTo(aPath, newName)
	local newPath, testPath
	
	tell application id "com.apple.Finder"
		set newPath to (parent of aPath) as string
		set testPath to (newPath & newName)
		if my pathExists(testPath) then
			error "Can't rename " & (name of aPath) & ": the renamed item exists already" number dupFNErr
		end if
		set the name of aPath to newName
	end tell
end renameFileTo

on localized_string(aString)
	return localized string aString in bundle with identifier "biz.lsd-ltd.otto.RegexFinderItems"
end localized_string
