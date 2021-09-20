//
//  FrameSubscribe.swift
//  CocoaMQTT
//
//  Created by JianBo on 2019/8/7.
//  Copyright © 2019 emqx.io. All rights reserved.
//

import Foundation


/// MQTT SUBSCRIBE Frame
struct FrameSubscribe: Frame {
    
    var packetFixedHeaderType: UInt8 = UInt8(FrameType.subscribe.rawValue + 2)
    
    // --- Attributes
    
    var msgid: UInt16
    
    //var topics: [(String, CocoaMQTTQoS)]
    
    // --- Attributes End


    //3.8.2 SUBSCRIBE Variable Header
    public var packetIdentifier: UInt16?

    //3.8.2.1.2 Subscription Identifier
    public var subscriptionIdentifier: UInt32?

    //3.8.2.1.3 User Property
    public var userProperty: [String: String]?

    //3.8.3 SUBSCRIBE Payload
    public var topicFilters: [MqttSubscription]

    
    init(msgid: UInt16, subscriptionList: [MqttSubscription]) {
        self.msgid = msgid
        self.topicFilters = subscriptionList
    }

}

extension FrameSubscribe {
    func fixedHeader() -> [UInt8] {
        var header = [UInt8]()
        header += [FrameType.subscribe.rawValue]

        return header
    }
    
    func variableHeader() -> [UInt8] {
        
        //3.8.2 SUBSCRIBE Variable Header
        //The Variable Header of the SUBSCRIBE Packet contains the following fields in the order: Packet Identifier, and Properties.


        //MQTT 5.0
        var header = [UInt8]()
        header = msgid.hlBytes
        header += beVariableByteInteger(length: self.properties().count)

        return header
    }
    
    func payload() -> [UInt8] {
        
        var payload = [UInt8]()

        for subscription in self.topicFilters {
            subscription.subscriptionOptions = true
            payload += subscription.subscriptionData
        }


        return payload
    }

    func properties() -> [UInt8] {
        var properties = [UInt8]()

        //3.8.2.1.2 Subscription Identifier
        if let subscriptionIdentifier = self.subscriptionIdentifier {
            properties += getMQTTPropertyData(type: CocoaMQTTPropertyName.subscriptionIdentifier.rawValue, value: subscriptionIdentifier.byteArrayLittleEndian)
        }

        //3.8.2.1.3 User Property
        if let userProperty = self.userProperty {
            let dictValues = [String](userProperty.values)
            for (value) in dictValues {
                properties += getMQTTPropertyData(type: CocoaMQTTPropertyName.userProperty.rawValue, value: value.bytesWithLength)
            }
        }

        return properties

    }

    func allData() -> [UInt8] {
        var allData = [UInt8]()

        allData += fixedHeader()
        allData += variableHeader()
        allData += properties()
        allData += payload()

        return allData
    }
}

extension FrameSubscribe: CustomStringConvertible {
    var description: String {
        var desc = ""
        for subscription in self.topicFilters {
            desc += "SUBSCRIBE(id: \(msgid), topics: \(subscription.topic))  "
        }
        return desc
    }
}
