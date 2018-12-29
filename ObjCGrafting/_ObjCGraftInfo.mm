//
//  _ObjCGraftInfo.mm
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#include "_ObjCGraftInfo.h"

namespace objcgrafting {
    _ObjCGraftInfo::_ObjCGraftInfo(__unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        this -> semantic_class = semantic_class;
        this -> composited_class = composited_class;
        this -> graft_record_map = std::make_unique<_ObjCGraftRecordMap>(graft_record_map);
    }
    
    bool _ObjCGraftInfo::push(Protocol * __unsafe_unretained *  protocols, __unsafe_unretained Class * source_classes, unsigned int count) {
        
        bool is_any_thing_modified = false;
        
        for (unsigned int index = 0; index < count; index ++) {
            auto protocol = protocols[index];
            auto source_class = source_classes[index];
            
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
}
