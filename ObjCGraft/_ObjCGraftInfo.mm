//
//  _ObjCGraftInfo.mm
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import "_ObjCGraftInfo.h"

namespace objcgraft {
    _ObjCGraftInfo::_ObjCGraftInfo(__unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        this -> semantic_class = semantic_class;
        this -> composited_class = composited_class;
        this -> graft_record_map = std::make_unique<_ObjCGraftRecordMap>(graft_record_map);
    }
    
    bool _ObjCGraftInfo::push(_ObjCGraftRequestVector& requests) {
        bool is_any_thing_modified = false;
        
        for (auto& request : requests) {
            auto protocol = request.first;
            auto source_class = request.second;
            
            auto position = graft_record_map -> find(protocol);
            
            if (position != graft_record_map -> cend()) {
                // The protocol has already been grafted.
                auto result = graft_record_map -> insert({protocol, source_class});
                is_any_thing_modified = result.second;
            } else {
                // The protocol has not been grafted.
                graft_record_map -> insert({protocol, source_class});
                is_any_thing_modified = true;
            }
        }
        
        return is_any_thing_modified;
    }
    
    bool _ObjCGraftInfo::pop(Protocol * __unsafe_unretained * protocols, unsigned int count) {
        
        bool is_any_thing_erased = false;
        
        for (unsigned int index = 0; index < count; index ++) {
            
            auto protocol = protocols[index];
            
            auto position = graft_record_map -> find(protocol);
            
            if (position != graft_record_map -> cend()) {
                graft_record_map -> erase(position);
                
                is_any_thing_erased = true;
            }
        }
        
        return is_any_thing_erased;
    }
    
    NSString * _ObjCGraftInfo::description() {
        NSMutableString * mutableDescription = [[NSMutableString alloc] init];
        
        [mutableDescription appendFormat: @"Semantic Class: %@\n", NSStringFromClass(this -> semantic_class)];
        
        [mutableDescription appendFormat: @"Composited Class: %@\n", NSStringFromClass(this -> composited_class)];
        
        for (auto& pair: * graft_record_map) {
            auto& key = pair.first;
            auto& value = pair.second;
            
            [mutableDescription appendFormat: @"\t@protocol(%@) => %@\n", NSStringFromProtocol(key), NSStringFromClass(value)];
        }
        
        return [mutableDescription copy];
    }
}
