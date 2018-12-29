//
//  _ObjCGraftInfo.mm
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#include "_ObjCGraftInfo.h"

namespace objcgrafting {
    _ObjCGraftInfo::_ObjCGraftInfo(__unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map) {
        this -> semantic_class = semantic_class;
        this -> composited_class = composited_class;
        this -> grafted_protocol_list = std::make_unique<_ObjCProtocolList>(grafted_protocol_list);
        this -> graft_record_map = std::make_unique<_ObjCGraftRecordMap>(graft_record_map);
    }
    
    bool _ObjCGraftInfo::push(Protocol * __unsafe_unretained *  protocols, __unsafe_unretained Class * source_classes, unsigned int count) {
        
        bool is_any_thing_modified = false;
        
        for (unsigned int index = 0; index < count; index ++) {
            auto protocol = protocols[index];
            auto source_class = source_classes[index];
            
            auto position_in_graft_record_map = graft_record_map -> find(protocol);
            
            if (position_in_graft_record_map != graft_record_map -> cend()) {
                auto pair = * position_in_graft_record_map;
                if (pair.second != source_class) {
                    graft_record_map -> insert({protocol, source_class});
                    is_any_thing_modified = true;
                }
            } else {
                graft_record_map -> insert({protocol, source_class});
                is_any_thing_modified = true;
            }
            
            if (position_in_graft_record_map != graft_record_map -> cend()) {
                // The protocol has already been grafted.
                auto position_in_grafted_protocol_list = std::find(grafted_protocol_list -> cbegin(), grafted_protocol_list -> cend(), protocol);
                
                assert(position_in_grafted_protocol_list != grafted_protocol_list -> cend());
                
                auto grafted_protocol = (* position_in_grafted_protocol_list);
                
                if (position_in_grafted_protocol_list != grafted_protocol_list -> cbegin()) {
                    grafted_protocol_list -> erase(position_in_grafted_protocol_list);
                    grafted_protocol_list -> push_front(grafted_protocol);
                    
                    is_any_thing_modified = true;
                }
                
            } else {
                // The protocol has not been grafted.
                grafted_protocol_list -> push_back(protocol);
                
                is_any_thing_modified = true;
            }
        }
        
        return is_any_thing_modified;
    }
    
    bool _ObjCGraftInfo::pop(Protocol * __unsafe_unretained * protocols, unsigned int count) {
        
        bool is_any_thing_erased = false;
        
        for (unsigned int index = 0; index < count; index ++) {
            
            auto protocol = protocols[index];
            
            graft_record_map -> erase(protocol);
            
            auto grafted_protocol_position = std::find(grafted_protocol_list -> cbegin(), grafted_protocol_list -> cend(), protocol);
            
            assert(grafted_protocol_position != grafted_protocol_list -> cend());
            
            grafted_protocol_list -> erase(grafted_protocol_position);
            
            is_any_thing_erased = true;
        }
        
        return is_any_thing_erased;
    }
}
