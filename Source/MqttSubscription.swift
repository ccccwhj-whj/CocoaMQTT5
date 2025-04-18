//
//  MqttSubscription.swift
//  CocoaMQTT
//
//  Created by liwei wang on 2021/7/15.
//

import Foundation

///3.8.3.1 Subscription Options
public class MqttSubscription {
 
    public var topic: String
    public var qos = CocoaMQTTQoS.qos1
    public var noLocal: Bool = false
    public var retainAsPublished: Bool = false
    public var retainHandling: CocoaRetainHandlingOption
    public var subscriptionOptions: Bool = false

    public init(topic: String, qos: CocoaMQTTQoS = CocoaMQTTQoS.qos1) {
        self.topic = topic
        self.qos = qos
        self.noLocal = false
        self.retainAsPublished = false
        self.retainHandling = CocoaRetainHandlingOption.none
    }

    var subscriptionData:[UInt8]{
        var data = [UInt8]()

        data += topic.bytesWithLength

        var options:Int = 0;
        switch qos {
        case .qos0:
            options = options | 0b0000_0000
        case .qos1:
            options = options | 0b0000_0001
        case .qos2:
            options = options | 0b0000_0010
        default:
            printDebug("topucFilter qos failure")
        }

        switch noLocal {
        case true:
            options = options | 0b0000_0100
        case false:
            options = options | 0b0000_0000
        }

        switch retainAsPublished {
        case true:
            options = options | 0b0000_1000
        case false:
            options = options | 0b0000_0000
        }

        switch retainHandling {
        case CocoaRetainHandlingOption.none:
            options = options | 0b0000_0000
        case CocoaRetainHandlingOption.sendOnlyWhenSubscribeIsNew:
            options = options | 0b0001_0000
        case CocoaRetainHandlingOption.sendOnSubscribe:
            options = options | 0b0010_0000
//        default:
//            printDebug("topucFilter retainHandling failure")
        }


        if subscriptionOptions {
            data += [UInt8(options)]
        }


        return data
    }

}
