//
//  Data+Extensions.swift
//  Submitted
//
//  Created by Geoff Raeder on 9/23/21.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: String {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: String.Encoding.utf8) else { return "" }

        return prettyPrintedString
    }
}
