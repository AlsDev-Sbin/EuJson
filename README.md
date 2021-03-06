# EuJson

`Português (Brasil 🇧🇷)`

<br>

Biblioteca pra realizar parser de json na linguagem de programação Euphoria.

Já existe uma forma de fazer parser de json em Euphoria, porém a forma existente, eu não achei interessante visto que pra cada get ou modificação é necessário parsear novamente os dados, isso ocorre sem eu precisar olhar detalhes de implementação, porém quando é necessário algo performático, vai vai deixar a desejar. No princípio a vontade era de criar um parser de json pra um aplicativo que eu precisava construir pra o trabalho, porém devido ao alto custo(tempo) de desenvolvimento da biblioteca, decidi utilizar o parser já existente [json.e](https://github.com/OpenEuphoria/euphoria-mvc/blob/v1.15.0/include/mvc/json.e). Mas agora vou realmente criar o meu parser.

Veja, não é apenas passar como argumento uma string json, pra uma biblioteca de parser json([json.e](https://github.com/OpenEuphoria/euphoria-mvc/blob/v1.15.0/include/mvc/json.e)) e receber um objeto(costumeiramente um dictionary, hash table, ...). É na verdade construir uma biblioteca do zero com o máximo de código built-in da linguagem e com o tedendo a 0 o números de dependências e 100% cross-plataform.<br/>

Será utilizado **hash table** para criar os objetos, se caso o valor de uma chave json for um objeto, então valor do item do **hash table** também será um novo **hash table**.

Exemplo abaixo.

<br/>

Para capturar um item do objeto desserializado, é possível chamar a função jsGet, onde possuí um padrão de acesso a itens bem parecido com linguagens tradicionais POO, ex: **peoples[1].name**.

É possível chamar funções internas do jsGet, por exemplo **JFN_LENGTH** para pegar o comprimendo do array.

---

`English (Google translate)`

<br/>

Library to perform json parser in Euphoria programming language.

There is already a way to parse a json in Euphoria, but the existing way, I didn't find it interesting since for each get or modification it is necessary to parse the data again, this happens without me having to look at implementation details, but when something is needed performative, will leave something to be desired. At first I wanted to create a json parser for an application that I needed to build for work, but due to the high cost (time) of library development, I decided to use the existing parser [json.e](https://github.com/OpenEuphoria/euphoria-mvc/blob/v1.15.0/include/mvc/json.e). But now I will actually create my parser.

See, it's not just passing a json string as an argument, to a json parser library ([json.e](https://github.com/OpenEuphoria/euphoria-mvc/blob/v1.15.0/include/mvc/json.e)) and receiving an object (usually a dictionary, hash table, ...). It's actually building a library from scratch with as much of the language's built-in code and with the number of dependencies as 0 and 100% cross-platform.

The hash table will be used to create the objects, if the value of a json key is an object, then the value of the hash table item will also be a new hash table.<br/>

Examples:

```euphoria
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
```

Return

```
name: Andre | age: 24
name: Milca | age: 26
name: Dante | age: 0.7
```



To capture an item from the deserialized object, it is possible to call the jsGet function, which has a pattern for accessing items very similar to traditional OOP languages, ex: **peoples[1].name**.

It is possible to call jsGet built-in functions, for example **JFN_LENGTH** to get the length of the array.
