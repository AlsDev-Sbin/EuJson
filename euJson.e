namespace json
include std\map.e
include std\convert.e
include std\utils.e

constant 
	TRUE = 1,
	FALSE = 0,
	NUMBERS = {'0','1','2','3','4','5','6','7','8','9'}
	
global
	map:map expecteds = map:new()

type bool(atom b)
    return b = 0 or b = 1
end type



public function deserialize(sequence strJson)
	map:map objJson = map:new()
	atom char = '\0'
	integer numbers_continue = 0
	sequence words = {}
	sequence nameKey = {}
	bool openKey = FALSE
	bool openValue = FALSE
	sequence currentValueExpected = {"undefined"}
	
	
	if map:size(expecteds) = 0 then
		map:put(expecteds, "\"", {"undefined"})
		map:put(expecteds, ":", {"value", '[', '{', '"', '0','1','2','3','4','5','6','7','8','9', "true", "false"})
		map:put(expecteds, ",", {"undefined"})
		map:put(expecteds, "{", {"key", '"'})
		map:put(expecteds, "}", {"undefined", ','})
		map:put(expecteds, "[", {"valueOrKey", '[', '{', '"', '0','1','2','3','4','5','6','7','8','9', "true", "false"})
		map:put(expecteds, "]", {"undefined", ','})
	end if
	
	for i = 1 to length(strJson) do
	    
	    char = strJson[i]
	    
	    if numbers_continue > 0 then
	        numbers_continue -= 1
	        continue
		
	    end if
	    
	    if find(char, {" ", "\t"}) then
	        continue
	    
	    -- OPEN KEY JSON
	    elsif	equal(char,  '"') and
				(length(currentValueExpected) > 0 and
				find(currentValueExpected[1], {"key", "undefined"})) 
			then
			
			nameKey = get_text(strJson, i+1)
			numbers_continue = length(nameKey)+1
			words = {}
			
--		    info(nameKey, char, i, currentValueExpected, openKey, openValue)
		    continue
			
		elsif equal(char, ':') then
		    words = {}
		    currentValueExpected = map:get(expecteds, ":")
		    
--		    info(words, char, i, currentValueExpected, openKey, openValue)
		
		elsif equal(char, ',') then
		    currentValueExpected = map:get(expecteds, ",")
		    
		    
--		    info(words, char, i, currentValueExpected, openKey, openValue)
		    
		-- OPEN VALUES ARRAY
		elsif equal(char, '[') then
		    currentValueExpected = map:get(expecteds, "[")
		    
--		    info(words, char, i, currentValueExpected, openKey, openValue)
		    
		-- OPEN VALUES NUMERIC OF JSON FROM KEY
		elsif find(char, NUMBERS) and not equal(nameKey, "") then
		    
			words = get_numbers(strJson, i)
			map:put(objJson, nameKey, words)
			numbers_continue = length(words)-1
			currentValueExpected = {"undefined"}
			nameKey = {}
			words = {}
			
--		    info(words, char, i, currentValueExpected, openKey, openValue)
		
		-- OPEN VALUES TEXT OF JSON FROM KEY
		elsif	equal(char, '"') and
				find(char, currentValueExpected)
			then
		    
		    words = get_text(strJson, i+1)
			map:put(objJson, nameKey, words)
			currentValueExpected = {"undefined"}
			nameKey = {}
			numbers_continue = length(words)+2
		    
--		    info(words, char, i, currentValueExpected, openKey, openValue)
		    continue
		
		-- OPEN VALUES BOOL(true) OF JSON FROM KEY
		elsif	equal(char, 't') and
				find("true", currentValueExpected)
			then
			
			if length(strJson) >= i+3 then
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
			
			if length(strJson) >= i+4 then
			    if equal(strJson[i..i+4], "false") then
			        map:put(objJson, nameKey, 0)
			        numbers_continue = 3
			    end if
			end if
			
		    currentValueExpected = {"undefined"}
		    nameKey = {}
		    words = {}
		    
--		    info(words, char, i, currentValueExpected, openKey, openValue)
			
	    elsif (openKey or openValue) then
	        words &= char
	        
		elsif (openValue) then
		    
	    end if
	        
	    
	end for
	
	return objJson
end function


procedure info(sequence words, atom char, integer i, sequence currentValueExpected, bool openKey, bool openValue)    
	puts(1,
		"words: "&words&"\n"&
		"char: "&char&"\n"&
		"i: "& to_string(i) &"\n"&
		"openKey: "& iff(openKey, "true", "false") &"\n"&
		"openValue: "& iff(openValue, "true", "false") &"\n"
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



















