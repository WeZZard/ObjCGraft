//
//  _ObjCCompositedClassManager.h
//  ObjCGrafting
//
//  Created on 30/12/2018.
//

#ifndef _ObjCProtocolManager_h
#define _ObjCProtocolManager_h

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#include <memory>
#include <unordered_set>
#include <unordered_map>

#import "ObjCGraftCommon.h"
#import "_ObjCGraftCombination.h"

namespace objcgrafting {
    typedef std::unordered_map<Protocol * __unsafe_unretained, std::unique_ptr<_ObjCProtocolList>, _ObjCProtocolHasher> _ObjCProtocolGraph;
    typedef std::unordered_set<Protocol * __unsafe_unretained, _ObjCProtocolHasher> _ObjCProtocolUnorderedSet;
    
    /// Manages composited class in grafting.
    ///
    /// This class doesn't need a lock. Because all its users all designed
    /// to be synchronized.
    ///
    struct _ObjCGraftingResolver {
#pragma mark Accessing Shared Instance
    public:
        static _ObjCGraftingResolver& shared();
        
#pragma mark Resolving Grafting
    public:
        std::unique_ptr<_ObjCGraftCombinationList> resolveGraftCombinationList(_ObjCGraftRecordMap& graft_record_map);
        NSString * graftedProtocolIdentifier(_ObjCGraftRecordMap& graft_record_map);
    private:
        std::unique_ptr<_ObjCProtocolUnorderedSet> _resolveNetTopmostGraftedProtocols(_ObjCGraftRecordMap& graft_record_map);
        
#pragma mark Accessing Elements in Registered Protocol Graph
        _ObjCProtocolGraph& _registeredProtocolGraph();
        bool _isProtocolRegistered(Protocol * __unsafe_unretained protocol);
        _ObjCProtocolList& _conformedProtocolsForRegisteredProtocol(Protocol * __unsafe_unretained protocol);
        void _registerConformedProtocolsForProtocol(Protocol * __unsafe_unretained protocol, _ObjCProtocolList& protocol_list);
        
#pragma mark Instance Variables
        std::unique_ptr<_ObjCProtocolGraph> registered_protocol_graph_;
        
#pragma mark Managing Life-Cycle
    protected:
        _ObjCGraftingResolver() {
            registered_protocol_graph_ = std::make_unique<_ObjCProtocolGraph>();
        }
        
        ~_ObjCGraftingResolver() {
            
        }
#pragma mark Operator Overloads
    public:
        _ObjCGraftingResolver(_ObjCGraftingResolver const&) = delete;             // Copy construct
        _ObjCGraftingResolver(_ObjCGraftingResolver&&) = delete;                  // Move construct
        _ObjCGraftingResolver& operator=(_ObjCGraftingResolver const&) = delete;  // Copy assign
        _ObjCGraftingResolver& operator=(_ObjCGraftingResolver &&) = delete;      // Move assign
    };
}

#endif /* _ObjCProtocolManager_h */
