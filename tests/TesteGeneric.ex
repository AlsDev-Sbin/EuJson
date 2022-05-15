namespace main
include ..\euJson.e
include std\console.e
include std\map.e
include std\convert.e

procedure main()
    
    sequence strJson = """
        {
            "pessoas": [
                {
                    "nome": "Andre",
                    "idade": 24,
                },
                {
                    "nome": "Milca",
                    "idade": 26,
                },
                {
                    "nome": "Dante",
                    "idade": 0.7,
                }
            ]
        }
    """
    
    sequence name, age
    map:map objJson = json:deserialize(strJson)

    for i = 1 to 3 do
        name = map:get(map:get(map:get(objJson, "pessoas"), "i"&to_string(i)), "nome")
        age = map:get(map:get(map:get(objJson, "pessoas"), "i"&to_string(i)), "idade")
        puts(1, "name: "&name&" | age: "&age&"\n")
        
    end for
end procedure


main()
any_key()
