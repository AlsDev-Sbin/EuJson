namespace main
include ..\euJson.e
include std\console.e
include std\convert.e

procedure main()
    
    sequence strJson = """
        [0, -1, 3, 7.3, "Hello word", false, true, [], {}]
    """
    
    object
        value,
        objJson = euJson:deserialize(strJson)

    for i = 1 to euJson:jsGet(objJson, "[]", JFN_LENGTH) do
        value = euJson:jsGet(objJson, "["&to_string(i)&"]")
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
