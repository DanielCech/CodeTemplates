import Stencil

struct Article {
    let title: String
    let author: String
}

let name = "example"

var context: Context = [
    "name": "example",
    "articles": [
        Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
        Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
    ],
    "cases": [
        "blue", "green", "yellow"
    ]
]

//context["name"] = name.decapitalizingFirstLetter()
//context["Name"] = name.capitalizingFirstLetter()





// Code generation
try generate(template: .viewControllerRxSwift, context: context)





