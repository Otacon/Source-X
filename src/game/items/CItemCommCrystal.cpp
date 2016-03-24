
#include "CItemCommCrystal.h"
#include "CItemVendable.h"

CItemCommCrystal::CItemCommCrystal( ITEMID_TYPE id, CItemBase * pItemDef ) : CItemVendable( id, pItemDef ) {
}

CItemCommCrystal::~CItemCommCrystal() {
    DeletePrepare();	// Must remove early because virtuals will fail in child destructor.
}

lpctstr const CItemCommCrystal::sm_szLoadKeys[] =
        {
                "SPEECH",
                NULL,
        };

void CItemCommCrystal::OnMoveFrom()
{
    ADDTOCALLSTACK("CItemCommCrystal::OnMoveFrom");
    // Being removed from the top level.
    CSector *pSector = GetTopSector();
    if ( pSector )
        pSector->RemoveListenItem();
}

// Move this item to it's point in the world. (ground/top level)
bool CItemCommCrystal::MoveTo(CPointMap pt, bool bForceFix)
{
    ADDTOCALLSTACK("CItemCommCrystal::MoveTo");
    CSector *pSector = pt.GetSector();
    ASSERT(pSector);
    pSector->AddListenItem();
    return CItem::MoveTo(pt, bForceFix);
}

void CItemCommCrystal::OnHear(lpctstr pszCmd, CChar *pSrc)
{
    ADDTOCALLSTACK("CItemCommCrystal::OnHear");
    // IT_COMM_CRYSTAL
    // STATF_COMM_CRYSTAL = if i am on a person.
    TALKMODE_TYPE mode = TALKMODE_SAY;
    for ( size_t i = 0; i < m_Speech.GetCount(); i++ )
    {
        CResourceLink *pLink = m_Speech[i];
        ASSERT(pLink);
        CResourceLock s;
        if ( !pLink->ResourceLock(s) )
            continue;
        TRIGRET_TYPE iRet = OnHearTrigger(s, pszCmd, pSrc, mode);
        if ( iRet == TRIGRET_ENDIF || iRet == TRIGRET_RET_FALSE )
            continue;
        break;
    }

    // That's prevent @ -1 crash speech :P
    if ( *pszCmd == '@' )
        return;

    if ( m_uidLink.IsValidUID() )
    {
        // I am linked to something ?
        // Transfer the sound.
        CItem *pItem = m_uidLink.ItemFind();
        if ( pItem && pItem->IsType(IT_COMM_CRYSTAL) )
            pItem->Speak(pszCmd);
    }
    else if ( m_Speech.GetCount() <= 0 )
        Speak(pszCmd);
}

void CItemCommCrystal::r_Write(CScript & s)
{
    ADDTOCALLSTACK_INTENSIVE("CItemCommCrystal::r_Write");
    CItemVendable::r_Write(s);
    m_Speech.r_Write(s, "SPEECH");
}

bool CItemCommCrystal::r_WriteVal(lpctstr pszKey, CGString & sVal, CTextConsole *pSrc)
{
    ADDTOCALLSTACK("CItemCommCrystal::r_WriteVal");
    switch ( FindTableSorted(pszKey, sm_szLoadKeys, COUNTOF(sm_szLoadKeys) - 1) )
    {
        case 0:
            m_Speech.WriteResourceRefList(sVal);
            break;
        default:
            return CItemVendable::r_WriteVal(pszKey, sVal, pSrc);
    }
    return true;
}

bool CItemCommCrystal::r_LoadVal(CScript & s)
{
    ADDTOCALLSTACK("CItemCommCrystal::r_LoadVal");
    switch ( FindTableSorted(s.GetKey(), sm_szLoadKeys, COUNTOF(sm_szLoadKeys) - 1) )
    {
        case 0:
            return m_Speech.r_LoadVal(s, RES_SPEECH);
        default:
            return CItemVendable::r_LoadVal(s);
    }
}

void CItemCommCrystal::DupeCopy(const CItem *pItem)
{
    ADDTOCALLSTACK("CItemCommCrystal::DupeCopy");
    CItemVendable::DupeCopy(pItem);

    const CItemCommCrystal *pItemCrystal = dynamic_cast<const CItemCommCrystal *>(pItem);
    if ( !pItemCrystal )
        return;

    m_Speech.Copy(&pItemCrystal->m_Speech);
}
