/**
* @file CSFileObjContainer.h
*/

#ifndef _INC_CSFILEOBJCONTAINER_H
#define _INC_CSFILEOBJCONTAINER_H

#include "CScriptObj.h"
#include <vector>

class CSFileObj;


class CSFileObjContainer : public CScriptObj
{
private:
    std::vector<CSFileObj *> sFileList;
    int iFilenumber;
    int64 iGlobalTimeout;   // in ticks
    int iCurrentTick;
    // ----------- //
    static lpctstr const sm_szLoadKeys[];
    static lpctstr const sm_szVerbKeys[];

private:
    void ResizeContainer( size_t iNewRange );

public:
    static const char *m_sClassName;
    CSFileObjContainer();
    ~CSFileObjContainer();

private:
    CSFileObjContainer(const CSFileObjContainer& copy);
    CSFileObjContainer& operator=(const CSFileObjContainer& other);

public:
    int GetFilenumber(void);
    void SetFilenumber(int);

public:
    bool OnTick();
    int FixWeirdness();

    virtual bool r_GetRef( lpctstr & pszKey, CScriptObj * & pRef );
    virtual bool r_LoadVal( CScript & s );
    virtual bool r_WriteVal( lpctstr pszKey, CSString &sVal, CTextConsole * pSrc );
    virtual bool r_Verb( CScript & s, CTextConsole * pSrc );

    lpctstr GetName() const
    {
        return "FILE_OBJCONTAINER";
    }
};

#endif // _INC_CSFILEOBJCONTAINER_H
