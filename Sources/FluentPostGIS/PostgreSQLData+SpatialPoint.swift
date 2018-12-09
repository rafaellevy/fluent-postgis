//
//  PostgreSQLData+SpatialPoint.swift
//  App
//
//  Created by Phil Larson on 11/30/18.
//

import Foundation
import PostgreSQL
import WKCodable

public struct PostGISPoint: Codable, Equatable {
    /// The point's longitude coordinate.
    public var longitude: Double
    
    /// The point's latitude coordinate.
    public var latitude: Double
    
    /// Create a new `ST_Point`
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

extension PostGISPoint: CustomStringConvertible {
    public var description: String {
        return "(\(longitude),\(latitude))"
    }
}

extension PostGISPoint: PostgreSQLDataConvertible {
    public static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> PostGISPoint {
        if let value = data.binary {
            let decoder = WKBDecoder()
            let point = try decoder.decode(from: value) as! WKBPoint
            return .init(longitude: point.x, latitude: point.y)
        } else {
            throw PostGISError.decode(self, from: data)
        }
    }

    public func convertToPostgreSQLData() throws -> PostgreSQLData {
        let encoder = WKBEncoder(byteOrder: .littleEndian)
        let data = try encoder.encode(WKBPoint(vector: [self.longitude, self.latitude], srid: FluentPostGISSrid))
        return PostgreSQLData(.geometry, binary: data)
    }
}
