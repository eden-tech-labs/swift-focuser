//
//  File.swift
//  
//
//  Created by Augustinas Malinauskas on 01/09/2021.
//

import SwiftUI
import Introspect

class TextFieldObserver: NSObject, UITextFieldDelegate {
    var originalObserver: UITextFieldDelegate?
    var onReturnTap: () -> () = {}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        originalObserver?.textFieldShouldReturn?(textField)
        onReturnTap()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return originalObserver?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        originalObserver?.textFieldDidBeginEditing?(textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return originalObserver?.textFieldShouldEndEditing?(textField) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        originalObserver?.textFieldDidEndEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        originalObserver?.textFieldDidEndEditing?(textField, reason: reason)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return originalObserver?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        originalObserver?.textFieldDidChangeSelection?(textField)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return originalObserver?.textFieldShouldClear?(textField) ?? true
    }

}

public struct FocusModifier<Value: FocusStateCompliant & Hashable>: ViewModifier {
    @Binding var focusedField: Value?
    var equals: Value
    @State var observer = TextFieldObserver()
    
    public func body(content: Content) -> some View {
        content
            .introspectTextField { tf in
                observer.originalObserver = tf.delegate
                tf.delegate = observer
                
                /// when user taps return we navigate to next responder
                observer.onReturnTap = {
                    focusedField = focusedField?.next ?? Value.last
                    
                    if equals.hashValue == Value.last.hashValue {
                        tf.resignFirstResponder()
                    }
                }

                /// to show kayboard with `next` or `return`
                if equals.hashValue == Value.last.hashValue {
                    tf.returnKeyType = .done
                } else {
                    tf.returnKeyType = .next
                }
                
                if focusedField == equals {
                    tf.becomeFirstResponder()
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
              focusedField = equals
            })
    }
}
