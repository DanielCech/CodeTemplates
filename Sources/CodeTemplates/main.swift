import Stencil
import ScriptToolkit

let projectPath = "/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS/Harbor/Scenes/LibraryScene"
var context: Context = ["name": "library"]

// Project setup
context["author"] = "Daniel Cech"
context["projectName"] = "Harbor"
context["copyright"] = "Copyright © 2020 25MP Corp. All rights reserved."

context["oldTableCells"] = [
    "blue", "green", "yellow"
]

context["newTableCells"] = [
    "blue", "green", "yellow"
]




print("⌚️ Processing")

// Code generation

do {
    try Generator.shared.generate(
        generationMode: .combo(.sceneControllerRxSwiftWithTableView),
        context: context,
        reviewMode: .individual
    )
}
catch {
    print("Error: generation failed: \(error)")
}



print("✅ Done")


