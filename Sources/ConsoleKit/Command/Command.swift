/// A command that can be run through a `Console`.
///
/// Both `Command` and `CommandGroup` conform to `AnyCommand` which provides the basic requirements
/// all command-like types need. In addition to those types, a `Command` requires zero or more `CommandArgument`s.
///
/// Below is a sample command that generates ASCII picture of a cow with a message.
///
///     struct CowsayCommand: Command {
///         public struct Signature: CommandSignature {
///             @Argument(name: "message")
///             var message: String
///
///             @Option(name: "eyes", short: "e")
///             var eyes: String?
///
///             @Option(name: "tongue", short: "t")
///             var tongue: String?
///
///             public init() { }
///         }
///
///         var help: String {
///             "Generates ASCII picture of a cow with a message."
///         }
///
///         public init() { }
///         public func run(using context: CommandContext, signature: Signature) throws {
///             let eyes = signature.eyes ?? "oo"
///             let tongue = signature.tongue ?? " "
///             let padding = String(repeating: "-", count: message.count)
///             let text: String = """
///               \(padding)
///             < \(message) >
///               \(padding)
///                       \\   ^__^
///                        \\  (\(eyes)\\_______
///                           (__)\\       )\\/\\
///                             \(tongue)  ||----w |
///                                ||     ||
///             """
///             context.console.print(text)
///         }
///     }
///
/// Meanwhile you can use the Command in an executable target like:
///
///     let console: Console = Terminal()
///     var input = CommandInput(arguments: CommandLine.arguments)
///     var context = CommandContext(console: console, input: input)
///
///     try console.run(CoswayCommand(), with: context)
///
/// Use `Commands` to register commands and create a `CommandGroup`.
///
/// - note: You can also use `console.run(...)` to run an `AnyCommand` manually.
///
/// Here is a simple example of the command in action, assuming it has been registered as `"cowsay"`.
///
///     swift run cowsay Hello
///       -----
///     < Hello >
///       -----
///               \   ^__^
///                \  (oo\_______
///                   (__)\       )\/\
///                        ||----w |
///                        ||     ||
///
/// And an example with flags:
///
///     swift run cowsay "I'm a dead cow" -e xx -t U
///       --------------
///     < I'm a dead cow >
///       --------------
///               \   ^__^
///                \  (xx\_______
///                   (__)\       )\/\
///                     U  ||----w |
///                        ||     ||
///
public protocol Command: AnyCommand {
    associatedtype Signature: CommandSignature
    func run(using context: CommandContext, signature: Signature) throws
}

extension Command {
    public func run(using context: inout CommandContext) throws {
        let signature = try Signature(from: &context.input)
        try self.run(using: context, signature: signature)
    }

    public func outputAutoComplete(using context: inout CommandContext) {
        var autocomplete: [String] = []
        autocomplete += Signature.reference.arguments.map { $0.name }
        autocomplete += Signature.reference.options.map { "--" + $0.name }
        context.console.output(autocomplete.joined(separator: " "), style: .plain)
    }

    public func outputHelp(using context: inout CommandContext) {
        context.console.output("Usage: ".consoleText(.info) + context.input.executable.consoleText() + " ", newLine: false)

        for argument in Signature.reference.arguments {
            context.console.output(("<" + argument.name + "> ").consoleText(.warning), newLine: false)
        }

        for option in Signature.reference.options {
            if let short = option.short {
                context.console.output("[--\(option.name),-\(short)] ".consoleText(.success), newLine: false)
            } else {
                context.console.output("[--\(option.name)] ".consoleText(.success), newLine: false)
            }
        }

        for flag in Signature.reference.flags {
            if let short = flag.short {
                context.console.output("[--\(flag.name),-\(short)] ".consoleText(.info), newLine: false)
            } else {
                context.console.output("[--\(flag.name)] ".consoleText(.info), newLine: false)
            }
        }
        context.console.print()

        if !self.help.isEmpty {
            context.console.print()
            context.console.print(self.help)
        }

        let names = Signature.reference.options.map { $0.name }
            + Signature.reference.arguments.map { $0.name }
            + Signature.reference.flags.map { $0.name }

        let padding = names.longestCount + 2
        if Signature.reference.arguments.count > 0 {
            context.console.print()
            context.console.output("Arguments:".consoleText(.info))
            for argument in Signature.reference.arguments {
                context.console.outputHelpListItem(
                    name: argument.name,
                    help: argument.help,
                    style: .info,
                    padding: padding
                )
            }
        }

        if Signature.reference.options.count > 0 {
            context.console.print()
            context.console.output("Options:".consoleText(.info))
            for option in Signature.reference.options {
                context.console.outputHelpListItem(
                    name: option.name,
                    help: option.help,
                    style: .success,
                    padding: padding
                )
            }
        }

        if Signature.reference.flags.count > 0 {
            context.console.print()
            context.console.output("Flags:".consoleText(.info))
            for option in Signature.reference.flags {
                context.console.outputHelpListItem(
                    name: option.name,
                    help: option.help,
                    style: .success,
                    padding: padding
                )
            }
        }
    }
}
