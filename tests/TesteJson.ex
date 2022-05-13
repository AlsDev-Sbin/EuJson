namespace main
include ..\euJson.e
include std\console.e
include std\map.e

procedure main()
    
--    sequence strJson = """
--        {
--            "pessoas": [
--                {
--                    "nome": "Andre",
--                    "idade": 24,
--                },
--                {
--                    "nome": "Milca",
--                    "idade": 26,
--                },
--                {
--                    "nome": "Dante",
--                    "idade": 0,
--                }
--            ]
--        }
--    """
    sequence strJson = """
        {
            "nome": "Andre",
            "idade": 24,
            "peso": 93.5,
            "ativo": true,
            "array": [1,2,3]
        }
    """
    
    map:map objJson = json:deserialize(strJson)
    
    puts(1, "\n\n")
    puts(1, "nome: "&map:get(objJson, "nome")&"\n")
    puts(1, "idade: "&map:get(objJson, "idade")&"\n")
    puts(1, "peso: "&map:get(objJson, "peso")&"\n")
    puts(1, "array: "&map:get(objJson, "array")&"\n")
    puts(1, "ativo: ")
    ? map:get(objJson, "ativo")
    
end procedure


main()
any_key()
