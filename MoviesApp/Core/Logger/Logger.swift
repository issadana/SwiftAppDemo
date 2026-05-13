//
//  Logger.swift
//  MoviesApp
//

import Foundation

/// Log level enum for severity filtering.
enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3

    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Protocol for logger implementations; allows swapping ConsoleLogger for remote logging later.
protocol LoggerProtocol: Sendable {
    func log(
        _ message: String,
        level: LogLevel,
        category: String,
        file: String,
        function: String,
        line: Int
    )
}

/// Console logger for development; outputs to Xcode console with formatted timestamps.
final class ConsoleLogger: LoggerProtocol {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    private let minimumLevel: LogLevel

    init(minimumLevel: LogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }

    func log(
        _ message: String,
        level: LogLevel,
        category: String,
        file: String,
        function: String,
        line: Int
    ) {
        guard level >= minimumLevel else { return }

        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = """
        \(level.emoji) [\(timestamp)] \(category) | \(fileName):\(line) \(function)
        \(message)
        """
        print(logMessage)
    }
}

/// Centralized logger instance accessible app-wide.
final class Logger {
    static let shared: LoggerProtocol = ConsoleLogger(minimumLevel: .debug)

    /// Convenience method for debug logs.
    static func debug(
        _ message: String,
        category: String = "App",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(message, level: .debug, category: category, file: file, function: function, line: line)
    }

    /// Convenience method for info logs.
    static func info(
        _ message: String,
        category: String = "App",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(message, level: .info, category: category, file: file, function: function, line: line)
    }

    /// Convenience method for warning logs.
    static func warning(
        _ message: String,
        category: String = "App",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(message, level: .warning, category: category, file: file, function: function, line: line)
    }

    /// Convenience method for error logs.
    static func error(
        _ message: String,
        category: String = "App",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(message, level: .error, category: category, file: file, function: function, line: line)
    }
}
