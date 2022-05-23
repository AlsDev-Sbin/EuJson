namespace euJson

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

enum type JSON_TYPE
	J_STRING,
	J_NUMBER,
	J_BOOL,
	J_ARRAY,
	J_OBJECT
end type

public enum type JSON_TYPE_FUNC
	JFN_NONE,
	JFN_LENGTH
end type

public function deserialize(sequence strJson)
	return _deserialize(strJson)
end function

--with trace
function _deserialize(sequence strJson, typeSearch currentSearch = NONE)
	map:map objJson = map:new()
	atom char = '\0'
	integer
		numbers_continue = 0,
		lenStrJson = length(strJson)
	sequence
		valueArray = {},
		words = {},
		nameKey = {},
		currentValueExpected = {"undefined"}
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
				find(currentValueExpected[1], {"valueOrKey", "key", "undefined"}))
			then
			trace(1)
			
			if currentSearch = ARRAY and equal(nameKey, {}) then
				words = get_text(strJson, i+1)
				numbers_continue = length(words)+1
				valueArray = append(valueArray, {J_STRING, words})
				continue
				
			elsif equal(nameKey, {}) then
				nameKey = get_text(strJson, i+1)
				numbers_continue = length(nameKey)+1
				continue
				
			elsif equal(words, {}) then
			    words = get_text(strJson, i+1)
			    numbers_continue = length(words)+1
			    
			else
				
				continue
			end if
			

			if currentSearch = ARRAY then
				valueArray = append(valueArray, {J_STRING, words})
			else
				map:put(objJson, nameKey, {J_STRING, words})
			end if
			nameKey = {}
			words = {}
			
		    continue
			
		elsif	equal(char, ':') then
		    words = {}
		    currentValueExpected = map:get(expecteds, ":")
		
		elsif	equal(char, ',') then
		    currentValueExpected = map:get(expecteds, ",")
		 
		-- CLOSE VALUES ARRAY   
		elsif	equal(char, ']') and currentSearch = ARRAY then
		trace(1)
			map:put(objJson, "array", {J_ARRAY, valueArray})
			return {i, objJson}
			
		-- OPEN VALUES ARRAY
		elsif	equal(char, '[') then
		trace(1)
		    currentValueExpected = {"undefined"}
		    sequence _valueArray = _deserialize(strJson[i+1..$], ARRAY)
		    
		    if map:size(objJson) = 0 and length(valueArray) = 0 and length(nameKey) > 0 then
				map:put(objJson, nameKey, {J_ARRAY, _valueArray[2]})
				
		    elsif map:size(objJson) = 0 and length(valueArray) = 0 then
		        objJson = _valueArray[2]
		        
			else
				valueArray = append(valueArray, {J_ARRAY, _valueArray[2]})
				
		    end if
		    numbers_continue = _valueArray[1]
			nameKey = {}
		    words = {}
	
		-- CLOSE VALUES OBJECT
		elsif	equal(char, '}') and currentSearch = OBJECT then
		    trace(1)
		    return {i, objJson}
		        
		-- OPEN VALUES OBJECT
		elsif	equal(char, '{') then
		trace(1)
--			if currentSearch != NONE then
				currentValueExpected = {"undefined"}
				sequence _valueArray = _deserialize(strJson[i+1..$], OBJECT)
				if currentSearch = ARRAY then
					valueArray = append(valueArray, {J_OBJECT, _valueArray[2]})
				
				elsif map:size(objJson) = 0 then
					objJson = _valueArray[2]
				else
					map:put(objJson, nameKey, {J_OBJECT, _valueArray[2]})
					
				end if
				
				
				numbers_continue = _valueArray[1]
				nameKey = {}
				words = {}
--		    end if
		    
		-- OPEN VALUES NUMERIC OF JSON FROM KEY
		elsif	find(char, {'-', '+'}) then
			trace(1)
			
			if lenStrJson >= i+1 then
				sequence nextSeqChar = strJson[i+1..i+1]
			    if find(nextSeqChar[1], NUMBERS) then
			        words = {char}
			        
			    end if
			    
			end if
			
		elsif	find(char, NUMBERS) then
		trace(1)
			numbers_continue = 0
		    if find(words, {"-", "+"}) then
		        words &= get_numbers(strJson, i)
		        numbers_continue -= 1 --Compensation for an unexpected character {'-', '+'}
		        
			else
				words = get_numbers(strJson, i)
				
		    end if
		    
		    if currentSearch = ARRAY and equal(nameKey, {}) then
		        valueArray = append(valueArray, {J_NUMBER, to_number(words)})
		        
			else
				map:put(objJson, nameKey, {J_NUMBER, to_number(words)})
				
		    end if
			numbers_continue += length(words)-1
			currentValueExpected = {"undefined"}
			nameKey = {}
			words = {}
		
		-- OPEN VALUES TEXT OF JSON FROM KEY
		elsif	equal(char, '"') and
				find(char, currentValueExpected)
			then
			trace(1)
		    
		    words = get_text(strJson, i+1)
			map:put(objJson, nameKey, {J_STRING, words})
			currentValueExpected = {"undefined"}
			numbers_continue = length(words)+1
		    nameKey = {}
		    words = {}
		    continue
		
		-- OPEN VALUES BOOL(true) OF JSON FROM KEY
		elsif	equal(char, 't') and
				find("true", currentValueExpected)
			then
			trace(1)
			if lenStrJson >= i+3 then
			    if equal(strJson[i..i+3], "true") then
					if currentSearch = ARRAY and equal(nameKey, {}) then
						valueArray = append(valueArray, {J_BOOL, -1})
						
					else
						map:put(objJson, nameKey, {J_BOOL, -1})
						
					end if
					numbers_continue = 3
					
				end if
			    
			end if
			
		    currentValueExpected = {"undefined"}
		    nameKey = {}
		    words = {}
		    
		elsif	equal(char, 'f') and
				find("false", currentValueExpected)
			then
			if lenStrJson >= i+4 then
			    if equal(strJson[i..i+4], "false") then
					if currentSearch = ARRAY and equal(nameKey, {}) then
						valueArray = append(valueArray, {J_BOOL, 0})
						
					else
						map:put(objJson, nameKey, {J_BOOL, 0})
						
					end if
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

--with trace
public function jsGet(map:map objJson, sequence objSelect, JSON_TYPE_FUNC FUNC = NONE)
    sequence
		keys = map:keys(objJson),
		separeteSelect = {},
		words = {},
		value, key
    atom
		char
	bool
		containObj = FALSE,
		containStr = FALSE, containNumber = FALSE,
		containArr = FALSE, containBool = FALSE
    
    -- PARSER OBJECT SELECTS
    for i = 1 to length(objSelect) do
        char = objSelect[i]
        
        if equal(char, '\'') then
            separeteSelect = append(separeteSelect, get_text(objSelect, i))
            words = {}
        
        elsif equal(char, '[') then
			separeteSelect = append(separeteSelect, words)
			words = {char}
			
		elsif equal(char, ']') then
			separeteSelect = append(separeteSelect, words & ']')
			words = {}
			
		elsif equal(char, '.') then
		    separeteSelect = append(separeteSelect, ".")
		    words = {}
		    
		else
			words &= char
			
        end if
        
    end for
    
    if length(words) > 0 then
        separeteSelect = append(separeteSelect, words)
    end if
    
		
	--< VALUES FROM RETURN OF MAP >
	sequence
		listKeys
	sequence
		valueString
	atom
		valueNumber,
		valueBool
	integer
		valueInteger
	object
		valueObject,
		valueArray
	--</ VALUES FROM RETURN OF MAP >
	
	trace(1)
    for i = 1 to length(separeteSelect) do
		
        key = separeteSelect[i]
        
        if	equal(key, {}) then
            continue
        elsif	map:has(objJson, key) or equal(key[1], '[') then
			trace(1)
			if	equal(key[1], '[') and map:has(objJson, "array") then
				integer y = to_integer(key[2..$-1])
				
				valueObject = map:get(objJson, "array")
				
				if y = 0 and FUNC = JFN_LENGTH then
				   return length(valueObject[2])
				    
				elsif length(valueObject) >= 2 then
					valueObject = valueObject[2]
					if length(valueObject) >= y then
					    value = valueObject[y]
					end if
					
				else
					return {}
					
				end if
			else
				value = map:get(objJson, key)
			end if
            
            if 	equal(value[1], J_STRING) then
                valueString = value[2]
				
				containNumber = FALSE
				containObj = FALSE
				containArr = FALSE
			    containBool = FALSE
                containStr = TRUE
                
			elsif	equal(value[1], J_BOOL) then
				valueBool = value[2]
				
				containStr = FALSE
				containNumber = FALSE
				containObj = FALSE
				containArr = FALSE
			    containBool = TRUE
			    
			elsif	equal(value[1], J_NUMBER) then
				valueNumber = value[2]
				
				containStr = FALSE
				containObj = FALSE
				containArr = FALSE
			    containBool = FALSE
			    containNumber = TRUE
			    
			elsif	equal(value[1], J_OBJECT) then
			    valueObject = value[2]
			    objJson = valueObject
			    
			    containStr = FALSE
				containNumber = FALSE
				containArr = FALSE
			    containBool = FALSE
			    containObj = TRUE
			    
			elsif	equal(value[1], J_ARRAY) then
			    valueArray = value[2]
			    objJson = valueArray
			    
			    containStr = FALSE
				containNumber = FALSE
				containObj = FALSE
			    containBool = FALSE
			    containArr = TRUE
			    
            end if
            
        end if
        
        
    end for
    
	trace(1)
	if containArr then
		valueArray =  map:get(valueArray, "array")
		valueArray = valueArray[2]
		sequence tmp = {}
		for i = 1 to length(valueArray) do
		    tmp = append(tmp, valueArray[i][2])
		end for
	    return tmp	
	    
	elsif containBool then
	    return valueBool
	    
	elsif containNumber then
	    return valueNumber
	    
	elsif containObj then
	    return valueObject
	    
	elsif containStr then
	    return valueString
	    
	end if
	
	return {}
    
end function

-- {VALOR, BOOL STRING, BOOL NUMBER, BOOL OBJ, BOOL BOOL, BOOL ARR}
function conditionGet(sequence value)
    return {
		value[2],
		equal(value[1], J_STRING),
		equal(value[1], J_NUMBER),
		equal(value[1], J_OBJECT),
		equal(value[1], J_BOOL),
		equal(value[1], J_ARRAY)}
end function

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



















