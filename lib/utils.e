namespace utils


public function split(sequence obj, sequence content)
	integer lenContent = length(content)
	if lenContent = 0 then
	    return {}
	    
	end if
	sequence result = repeat({}, lenContent/2)
	integer
		oldIndex = 1,
		index = 1
	
	while 1 do
		oldIndex = index
	    index = find(obj, content, index)
	    
	    if index > 0 then
	        result = append(result, content[oldIndex..index])
	        
		else
			exit
			
	    end if
	    
	end while
	
	return result
	
end function

public function iif(integer condition, object isEqual, object isNotEqual)
    if condition then
        return isEqual
	else
		return isNotEqual
    end if
end function
