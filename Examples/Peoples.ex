namespace main
include ..\euJson.e
include std\console.e
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
    
    sequence name
    atom age
    object objJson = euJson:deserialize(strJson)

    for i = 1 to euJson:jsGet(objJson, "pessoas[]", JFN_LENGTH) do
        name = euJson:jsGet(objJson, "pessoas["&to_string(i)&"].nome")
        age = euJson:jsGet(objJson, "pessoas["&to_string(i)&"].idade")
        puts(1, "name: "&name&" | age: "&to_string(age)&"\n")
        
    end for
end procedure


main()
any_key()
