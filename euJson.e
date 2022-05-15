namespace json
include std\map.e
include std\convert.e
include lib\utils.e

constant 
	TRUE = 1,
	FALSE = 0,
	NUMBERS = {'0','1','2','3','4','5','6','7','8','9'}
	
map:map expecteds = map:new()
	
constant
	CHARS_IGNORE = {' ', '\t', '\r', '\n'}

type bool(atom b)
    return b = 0 or b = 1
end type

enum type typeSearch
	NONE,
	ARRAY,
	OBJECT
end type

--with trace
public function deserialize(sequence strJson)
	return _deserialize(strJson)
end function

function _deserialize(sequence strJson, typeSearch currentSearch = NONE)
	map:map objJson = map:new()
	atom char = '\0'
	integer
		numbers_continue = 0,
		elementArray = 1,
		lenStrJson = length(strJson)
	sequence words = {}
	sequence nameKey = {}
	sequence currentValueExpected = {"undefined"}
	bool openKey = FALSE
	bool openValue = FALSE
	

	if map:size(expecteds) = 0 then
		map:put(expecteds, "\"", {"undefined"})
		map:put(expecteds, ":", {"value", '[', '{', '"', '0','1','2','3','4','5','6','7','8','9', "true", "false"})
		map:put(expecteds, ",", {"valueOrKey", '[', '{', '"', '0','1','2','3','4','5','6','7','8','9', "true", "false"})
		map:put(expecteds, "{", {"key", '"'})
		map:put(expecteds, "}", {"undefined", ','})
		map:put(expecteds, "[", {"valueOrKey", '[', '{', '"', '0','1','2','3','4','5','6','7','8','9', "true", "false"})
		map:put(expecteds, "]", {"undefined", ','})
		
	end if
	
	for i = 1 to lenStrJson do
--		trace(1)
	    char = strJson[i]
	    
	    if numbers_continue > 0 then
	        numbers_continue -= 1
	        continue
		
	    end if
	    
	    if find(char, CHARS_IGNORE) then
	        continue
	    
	    -- OPEN KEY JSON
	    elsif	equal(char,  '"') and
				(length(currentValueExpected) > 0 and
				find(currentValueExpected[1], {"key", "undefined"})) 
			then
			
			nameKey = get_text(strJson, i+1)
			numbers_continue = length(nameKey)+1
			words = {}
			
		    continue
		    
		elsif	equal(char,  '"') and
				(length(currentValueExpected) > 0 and
				find(currentValueExpected[1], {"valueOrKey"})) 
			then
			trace(1)
			if currentSearch = ARRAY and equal(nameKey, {}) then
				nameKey = "i"& to_string(elementArray)
				elementArray +=1
			end if
			
			words = get_text(strJson, i+1)
			numbers_continue = length(words)+1
			map:put(objJson, nameKey, words)
			words = {}
			nameKey = {}
			
		    continue
			
		elsif	equal(char, ':') then
		    words = {}
		    currentValueExpected = map:get(expecteds, ":")
		
		elsif	equal(char, ',') then
		    currentValueExpected = map:get(expecteds, ",")
		 
		-- CLOSE VALUES ARRAY   
		elsif	equal(char, ']') and currentSearch = ARRAY then
		trace(1)
			return {i, objJson}
			
		-- OPEN VALUES ARRAY
		elsif	equal(char, '[') then
		trace(1)
			if currentSearch = ARRAY and equal(nameKey, {}) then
				nameKey = "i"& to_string(elementArray)
				elementArray +=1
			end if
				
		    currentValueExpected = {"undefined"}
		    sequence valueArray = _deserialize(strJson[i+1..$], ARRAY)
		    if map:size(objJson) = 0 and equal(nameKey, {}) then
		        objJson = valueArray[2]
		        
			else
				map:put(objJson, nameKey, valueArray[2])
				
		    end if
		    numbers_continue = valueArray[1]
			nameKey = {}
		    words = {}
	
		-- CLOSE VALUES OBJECT
		elsif	equal(char, '}') and currentSearch = OBJECT then
		    trace(1)
		    return {i, objJson}
		    
		-- OPEN VALUES OBJECT
		elsif	equal(char, '{') then
		trace(1)
			if currentSearch != NONE then
				if currentSearch = ARRAY and equal(nameKey, {}) then
					nameKey = "i"& to_string(elementArray)
					elementArray +=1
				end if
		    
				currentValueExpected = {"undefined"}
				sequence valueArray = _deserialize(strJson[i+1..$], OBJECT)
				map:put(objJson, nameKey, valueArray[2])
				
				numbers_continue = valueArray[1]
				nameKey = {}
				words = {}
		    end if
		    
		-- OPEN VALUES NUMERIC OF JSON FROM KEY
		elsif	find(char, {'-', '+'}) then
			trace(1)
			
			if lenStrJson >= i+1 then
				sequence nextSeqChar = strJson[i+1..i+1]
			    if find(nextSeqChar[1], NUMBERS) then
			        words &= char
			        
			    end if
			    
			end if
			
		elsif	find(char, NUMBERS) then
		trace(1)
			numbers_continue = 0
		    if currentSearch = ARRAY and equal(nameKey, {}) then
		        nameKey = "i"& to_string(elementArray)
		        elementArray +=1
		        
		    end if
		    
		    if find(words, {"-", "+"}) then
		        words &= get_numbers(strJson, i)
		        numbers_continue -= 1 --Compensation for an unexpected character {'-', '+'}
		        
			else
				words = get_numbers(strJson, i)
				
		    end if
		    
			map:put(objJson, nameKey, words)
			numbers_continue += length(words)-1
			currentValueExpected = {"undefined"}
			nameKey = {}
			words = {}
		
		-- OPEN VALUES TEXT OF JSON FROM KEY
		elsif	equal(char, '"') and
				find(char, currentValueExpected)
			then
			trace(1)
			if currentSearch = ARRAY and equal(nameKey, {}) then
		        nameKey = "i"& to_string(elementArray)
		        elementArray +=1
		    end if
		    
		    words = get_text(strJson, i+1)
			map:put(objJson, nameKey, words)
			currentValueExpected = {"undefined"}
			numbers_continue = length(words)+2
		    nameKey = {}
		    words = {}
		    continue
		
		-- OPEN VALUES BOOL(true) OF JSON FROM KEY
		elsif	equal(char, 't') and
				find("true", currentValueExpected)
			then
			trace(1)
			if currentSearch = ARRAY and equal(nameKey, {}) then
		        nameKey = "i"& to_string(elementArray)
		        elementArray +=1
		        
		    end if
			
			if lenStrJson >= i+3 then
			    if equal(strJson[i..i+3], "true") then
			        map:put(objJson, nameKey, -1)
			        numbers_continue = 3
			        
			    end if
			    
			end if
			
		    currentValueExpected = {"undefined"}
		    nameKey = {}
		    words = {}
		    
--		    info(words, char, i, currentValueExpected, openKey, openValue)
		    
		elsif	equal(char, 'f') and
				find("false", currentValueExpected)
			then
			
			if currentSearch = ARRAY and equal(nameKey, {}) then
		        nameKey = "i"& to_string(elementArray)
		        elementArray +=1
		        
		    end if
			
			if lenStrJson >= i+4 then
			    if equal(strJson[i..i+4], "false") then
			        map:put(objJson, nameKey, 0)
			        numbers_continue = 4
			        
			    end if
			    
			end if
			
		    currentValueExpected = {"undefined"}
		    nameKey = {}
		    words = {}
	    end if
	        
	    
	end for
	
	return objJson
end function

public function getx(sequence objSelect, map:map objJson)
    
    sequence keys = map:keys(objJson)
    sequence separeteSelect = {}
    
    if find(".", objSelect) then
        separeteSelect = utils:split(".", objSelect)
        
	else
		separeteSelect = {objSelect}
		
    end if
    
    
    object value = {}
    for i = 1 to length(separeteSelect) do
		if find(separeteSelect[i], keys) then
		    value = map:get(objJson, separeteSelect[i])
		    
		end if
		
		
		if map:map(value) then
		    objJson = value
		    
		end if
		
    end for
    
--    for i = 1 to length(keys) do
--        if (find()) then
--            
--        end if
--    end for
	
	return value
    
end function

procedure info(sequence words, atom char, integer i, sequence currentValueExpected, bool openKey, bool openValue)    
	puts(1,
		"words: "&words&"\n"&
		"char: "&char&"\n"&
		"i: "& to_string(i) &"\n"&
		"openKey: "& iif(openKey, "true", "false") &"\n"&
		"openValue: "& iif(openValue, "true", "false") &"\n"
	)
	if length(currentValueExpected) then
	    puts(1,
			"expected: '"& currentValueExpected[1]& "'" & currentValueExpected[2..$-iif(length(currentValueExpected)>2, 2, 0)] &"\n"
	    )
	    
	end if
	
end procedure

function find_sequential(sequence search, sequence list)
	integer x = 1
    for i = 1 to length(list) do
        if length(search) >= x then
			if find(search[i], list) then
				return 1
				
			end if
			
        end if
        x += 1
        
    end for
    
    return 0
    
end function


-- GET NUMBER SEQUENCE TO THE END
function get_numbers(sequence lines, integer start = 1)
	sequence rowOfNumbers = {}
	bool startNumber = FALSE
	
    for i = start to length(lines) do
        if (find(lines[i], NUMBERS) or equal(lines[i], '.')) then
			startNumber = TRUE
            rowOfNumbers &= lines[i]
		
		elsif startNumber and length(rowOfNumbers) then
		    return rowOfNumbers
		
        end if
        
    end for
    
    return ""
    
end function


-- GET TEXT SEQUENCE TO THE END
function get_text(sequence line, integer start = 1)
	sequence text = {}
	bool startNumber = FALSE
	integer
		len_line = length(line),
		numContinues = 0
	
	
    for i = start to len_line do
		if numContinues > 0 then
		    numContinues -= 1
		    continue
		    
		end if
    
		if equal(line[i], '\\') then
		    if (len_line >= i+1) then
		        if equal(line[i+1], '"') then
		            text &= line[i..i+1]
		            numContinues += 1
		            continue
		            
				else
					text &= line[i]
					
		        end if
		        
			else
				text &= line[i]
				
		    end if
		else
			if equal(line[i], '"') then
			    return text
			end if
			
			text &= line[i]
			
		end if
		
    end for
    
    return text
    
end function



















