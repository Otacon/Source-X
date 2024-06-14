/**
* @file CWorldTicker.h
*/

#ifndef _INC_CWORLDTICKER_H
#define _INC_CWORLDTICKER_H

#include "CTimedFunctionHandler.h"
#include "CTimedObject.h"
#include <map>
//#include <unordered_set>

#ifdef _WIN32
    #undef SRWLOCK_INIT
#endif
#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wshift-count-overflow"
#endif
#include <parallel_hashmap/phmap.h>
#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif
//#include <flat_containers/flat_map.hpp>
#include <parallel_hashmap/btree.h>



class CObjBase;
class CChar;
class CWorldClock;

class CWorldTicker
{
public:
    static const char* m_sClassName;
    CWorldTicker(CWorldClock* pClock);
    ~CWorldTicker() = default;

private:
    //using TimedObjectsContainer = std::vector<CTimedObject*>;
    //struct WorldTickList : public std::map<int64, TimedObjectsContainer>
    //struct WorldTickList : public fc::vector_map<int64, TimedObjectsContainer>
    struct WorldTickList : public phmap::btree_multimap<int64, CTimedObject*>
    {
        THREAD_CMUTEX_DEF;
    };

    //using TimedCharsContainer = std::vector<CChar*>;
    //struct CharTickList : public std::map<int64, TimedCharsContainer>
    //struct CharTickList : public fc::vector_map<int64, TimedCharsContainer>
    struct CharTickList : public phmap::btree_multimap<int64, CChar*>
    {
        THREAD_CMUTEX_DEF;
    };

    struct StatusUpdatesList : public phmap::parallel_flat_hash_set<CObjBase*>
    //struct StatusUpdatesList : public std::unordered_set<CObjBase*>
    {
        THREAD_CMUTEX_DEF;
    };

    WorldTickList _mWorldTickList;
    CharTickList _mCharTickList;

    friend class CWorldTickingList;
    StatusUpdatesList _ObjStatusUpdates;   // objects that need OnTickStatusUpdate called

    // Reuse the same container (using void pointers statically casted) to avoid unnecessary reallocations.
    std::vector<void*> _vecObjs;
    // "Index" in the multimap
    std::vector<size_t> _vecWorldObjsToEraseFromList;
    // "Index" in the multimap
    std::vector<size_t> _vecPeriodicCharsToEraseFromList;

    //----

    friend class CWorld;
    friend class CWorldTimedFunctions;
    CTimedFunctionHandler _TimedFunctions; // CTimedFunction Container/Wrapper

    CWorldClock* _pWorldClock;
    int64        _iLastTickDone;  

public:
    void Tick();

    void AddTimedObject(int64 iTimeout, CTimedObject* pTimedObject, bool fForce);
    void DelTimedObject(CTimedObject* pTimedObject);
    void AddCharTicking(CChar* pChar, bool fNeedsLock);
    void DelCharTicking(CChar* pChar, bool fNeedsLock);
    void AddObjStatusUpdate(CObjBase* pObj, bool fNeedsLock);
    void DelObjStatusUpdate(CObjBase* pObj, bool fNeedsLock);

private:
    void _InsertTimedObject(const int64 iTimeout, CTimedObject* pTimedObject);
    void _RemoveTimedObject(const int64 iOldTimeout, CTimedObject* pTimedObject);
    void _InsertCharTicking(const int64 iTickNext, CChar* pChar);
    void _RemoveCharTicking(const int64 iOldTimeout, CChar* pChar);
};

#endif // _INC_CWORLDTICKER_H
