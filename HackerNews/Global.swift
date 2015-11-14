//
//  Extensions.swift
//  HackerNews
//
//  Created by alexchoi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


struct Shared {
    static let prototypeView = UIView()
}

func merge<K,V>(dicts: [K: V]...) -> [K: V] {
    var new = [K: V]()
    for dict in dicts {
        for (k,v) in dict {
            new[k] = v
        }
    }
    return new
}

func pmap<T,U>(array: Array<T>, closure: (T) -> U) -> Array<U> {
    var pmapped = Array<U>()
    dispatch_apply(array.count, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { (i) -> Void in
        pmapped.append(closure(array[i]))
    }
    return pmapped
}
