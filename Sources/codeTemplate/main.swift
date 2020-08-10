import Files
import Foundation
import Moderator
import ScriptToolkit
import Stencil

var programMode: ProgramMode

// The main context for code templates
var mainContext: Context

do {
    ContextProvider.setupParameters()
    try ContextProvider.parseParameters()

    if CommandLine.argc == 1 {
        print("codeTemplate - Generates a swift app components from templates")
        print("use argument `--help` for documentation")
    }

    ContextProvider.showUsageInfoIfNeeded()

    print("⌚️ Processing")

    mainContext = ContextProvider.getContext()
    mainContext = ContextProvider.updateContext(mainContext)
    mainContext = try Paths.setupPaths(context: mainContext)

    switch mainContext.stringValue(.mode) {
    case "generate":
        guard let reviewMode = ReviewMode(rawValue: mainContext.stringValue(.reviewMode)) else {
            throw ScriptError.argumentError(message: "invalid review mode")
        }

        try Generator.shared.generateCode(reviewMode: reviewMode, context: mainContext)

    case "updateAll":
        try Updater.shared.updateTemplates(updateMode: .all, scriptPath: mainContext.stringValue(.scriptPath))

    case "updateNew":
        try Updater.shared.updateTemplates(updateMode: .new, scriptPath: mainContext.stringValue(.scriptPath))

    case "validate":
        if let unwrappedTemplate = mainContext.optionalStringValue(.template) {
            try Validator.shared.validate(
                template: unwrappedTemplate,
                scriptPath: mainContext.stringValue(.scriptPath)
            )
        } else {
            // Validate all templates
            try Validator.shared.validateTemplates(scriptPath: mainContext.stringValue(.scriptPath))
        }

    case "prepare":
        try Preparator.shared.prepareTemplate()

    default:
        throw ScriptError.argumentError(message: "invalid mode value")
    }

    print("✅ Done")
} catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
