namespace main
include ..\euJson.e
include std\console.e
include std\sequence.e
include std\convert.e

procedure main()
    
    sequence strJson = """
        {
            "animal": [
                {
                    "type": "dog",
                    "name": "toto"
                },
                {
                    "type": "dog",
                    "name": "Bob"
                },
                {
                    "type": "cat",
                    "name": "mixie"
                },
                {
                    "type": "cat",
                    "name": "foxie"
                }
            ]
        }
    """

    object objJson = euJson:deserialize(strJson)
    
    sequence
        animal_type,
        animal_name,
        divider = join(repeat("-", 30), "")&"\n"
    
    for i = 1 to euJson:jsGet(objJson, "animal[]", euJson:JFN_LENGTH) do
         
         animal_type = euJson:jsGet(objJson, "animal["&to_string(i)&"].type")
         animal_name = euJson:jsGet(objJson, "animal["&to_string(i)&"].name")
         
         puts(1, "Type: "&animal_type&"\n")
         puts(1, "Name: "&animal_name&"\n")
         puts(1, divider)
    end for
end procedure


main()
any_key()
