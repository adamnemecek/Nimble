import Foundation

/// A Nimble matcher that succeeds when the actual value is an _exact_ instance of the given class.
public func beAnInstanceOf<T>(_ expectedType: T.Type) -> Predicate<Any> {
    let errorMessage = "be an instance of \(expectedType)"
    return .define { actualExpression in
        let instance = try actualExpression.evaluate()
        guard let validInstance = instance else {
            return PredicateResult(
                status: .doesNotMatch,
                message: .expectedActualValueTo(errorMessage)
            )
        }

        let actualString = "<\(type(of: validInstance)) instance>"

        return PredicateResult(
            status: PredicateStatus(bool: type(of: validInstance) == expectedType),
            message: .expectedCustomValueTo(errorMessage, actualString)
        )
    }
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAKindOf if you want to match against subclasses
public func beAnInstanceOf(_ expectedClass: AnyClass) -> Predicate<NSObject> {
    let errorMessage = "be an instance of \(expectedClass)"
    return .define { actualExpression in
        let instance = try actualExpression.evaluate()
        let actualString: String
        if let validInstance = instance {
            actualString = "<\(type(of: validInstance)) instance>"
        } else {
            actualString = "<nil>"
        }
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let matches = instance != nil && instance!.isMember(of: expectedClass)
        #else
            let matches = instance != nil && type(of: instance!) == expectedClass
        #endif
        return PredicateResult(
            status: PredicateStatus(bool: matches),
            message: .expectedCustomValueTo(errorMessage, actualString)
        )
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beAnInstanceOfMatcher(_ expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            return try! beAnInstanceOf(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
#endif
