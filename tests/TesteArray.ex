namespace main
include ..\euJson.e
include std\console.e
include std\map.e
include std\convert.e

procedure main()
    
    sequence strJson = """
        [0, -1, 3, 7.3, "Hello word", false, true, [], {}]
    """
    
    object value
    map:map objJson = json:deserialize(strJson)

    for i = 1 to 9 do
        value = map:get(objJson, "i"&to_string(i))
        if not sequence(value) then
            puts(1, "value: ")
            ? value
            continue
        end if
        puts(1, "value: "&to_string(value)&"\n")
        
    end for
end procedure


main()
any_key()
