// Playground generated with 🏟 Arena (https://github.com/finestructure/arena)
// ℹ️ If running the playground fails with an error "no such module ..."
//    go to Product -> Build to re-trigger building the SPM package.
// ℹ️ Please restart Xcode if autocomplete is not working.

import Stencil
import ScriptToolkit
import Files
import FileSmith
import Moderator
import SwiftShell

let folder = try Folder(path: "/Users/danielcech/Documents/[Development]/[Projects]/SwiftScripts/colorPalette/Tests")

struct Article {
  let title: String
  let author: String
}

let context = [
  "articles": [
    Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
    Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
  ]
]

let environment = Environment(loader: FileSystemLoader(paths: ["templates/"]))
let rendered = try environment.renderTemplate(name: "article_list.html", context: context)

print(rendered)
